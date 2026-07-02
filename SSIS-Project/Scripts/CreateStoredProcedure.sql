USE TimesheetDb;
GO

-- 1. DEPLOY STAGING TRUNCATION ENGINE
CREATE OR ALTER PROCEDURE dbo.usp_TruncateStagingTables
AS
BEGIN
    SET NOCOUNT ON;
    
    TRUNCATE TABLE stg.Timesheet;
    TRUNCATE TABLE stg.Leave;
END;
GO

-- 2. DEPLOY MAIN DELTA UPSERT PIPELINE ENGINE
CREATE OR ALTER PROCEDURE dbo.usp_ProcessStagingToMaster
    @CurrentFilePath VARCHAR(500) = 'Manual Execution / Unknown',
    @SSISTaskName VARCHAR(200) = 'Stored Procedure Execution',
    @PackageRunNumber INT = NULL 
AS
BEGIN
    SET NOCOUNT ON;

    -- 0. AUTOMATIC ROLLING CLEANUP (Enforces a max threshold to prevent bloat)
    IF (SELECT COUNT(*) FROM dbo.AuditLog) > 1000
    BEGIN
        DELETE FROM dbo.AuditLog
        WHERE LogID NOT IN (
            SELECT TOP 104 LogID 
            FROM dbo.AuditLog 
            ORDER BY LogDateTime DESC, LogID DESC
        );
    END;

    -- 1. TRACK TIME, EXECUTION USER & RUN METADATA
    DECLARE @CurrentRunNumber INT;
    
    IF @PackageRunNumber IS NOT NULL
        SET @CurrentRunNumber = @PackageRunNumber;
    ELSE
        SELECT @CurrentRunNumber = ISNULL(MAX(RunNumber), 0) + 1 FROM dbo.AuditLog;

    DECLARE @ExecutionUser VARCHAR(100) = CAST(SYSTEM_USER AS VARCHAR(100));

    -- Timing metrics
    DECLARE @StartTimeTS DATETIME2 = SYSDATETIME(), @EndTimeTS DATETIME2;
    DECLARE @StartTimeLV DATETIME2 = SYSDATETIME(), @EndTimeLV DATETIME2;

    -- Delta Metric Tracking Variables
    DECLARE @TS_Inserts INT = 0, @TS_Updates INT = 0;
    DECLARE @LV_Inserts INT = 0, @LV_Updates INT = 0;

    DECLARE @DefaultConsultantID INT, @DefaultClientID INT;
    SELECT TOP 1 @DefaultConsultantID = ConsultantID FROM dbo.Consultant;

    -- Pipelining lookups
    INSERT INTO dbo.Consultant (FirstName, LastName)
    SELECT DISTINCT NULLIF(TRIM(s.ConsultantFirstName), ''), NULLIF(TRIM(s.ConsultantLastName), '')
    FROM stg.Timesheet s
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.Consultant c WHERE c.FirstName = TRIM(s.ConsultantFirstName) AND c.LastName = TRIM(s.ConsultantLastName)
    ) AND s.ConsultantFirstName IS NOT NULL;

    INSERT INTO dbo.Client (ClientName)
    SELECT DISTINCT NULLIF(TRIM(s.Client), '')
    FROM stg.Timesheet s
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.Client cl WHERE cl.ClientName = TRIM(s.Client)
    ) AND s.Client IS NOT NULL;

    SELECT TOP 1 @DefaultClientID = ClientID FROM dbo.Client;

    -- 2. TIMESHEET MERGE
    SET @StartTimeTS = SYSDATETIME();
    DECLARE @TimesheetActions TABLE (ActionTaken VARCHAR(20));

    MERGE dbo.Timesheet AS target
    USING (
        SELECT 
            c.ConsultantID, TRY_CAST(s.[Date] AS DATE) AS [Date], MAX(s.[DayOfWeek]) AS [DayOfWeek],
            ISNULL(cl.ClientID, @DefaultClientID) AS ClientID, s.[Description], MAX(s.BillableType) AS BillableType, MAX(s.Comments) AS Comments,
            ISNULL(CAST(SUM(CASE WHEN s.TotalHours LIKE '%:%:%' THEN CAST(LEFT(s.TotalHours, CHARINDEX(':', s.TotalHours) - 1) AS DECIMAL(5,2)) + (CAST(SUBSTRING(s.TotalHours, CHARINDEX(':', s.TotalHours) + 1, 2) AS DECIMAL(5,2)) / 60.0) ELSE TRY_CAST(s.TotalHours AS DECIMAL(5,2)) END) AS DECIMAL(5,2)), 0.00) AS TotalHours,
            CAST(TRY_CAST(s.StartTime AS TIME(0)) AS TIME(0)) AS StartTime, CAST(MAX(TRY_CAST(s.EndTime AS TIME(0))) AS TIME(0)) AS EndTime
        FROM stg.Timesheet s
        JOIN dbo.Consultant c ON TRIM(s.ConsultantFirstName) = TRIM(c.FirstName) AND TRIM(s.ConsultantLastName) = TRIM(c.LastName)
        LEFT JOIN dbo.Client cl ON cl.ClientName = TRIM(s.Client)
        WHERE s.[Date] IS NOT NULL AND s.StartTime IS NOT NULL AND s.[Description] IS NOT NULL
        GROUP BY c.ConsultantID, TRY_CAST(s.[Date] AS DATE), cl.ClientID, s.[Description], TRY_CAST(s.StartTime AS TIME(0))
    ) AS source
    ON (target.ConsultantID = source.ConsultantID AND target.[Date] = source.[Date] AND target.StartTime = source.StartTime AND target.[Description] = source.[Description])
    WHEN MATCHED AND (target.HoursWorked != source.TotalHours OR ISNULL(target.Comments, '') != ISNULL(source.Comments, '') OR target.ClientID != source.ClientID) THEN
        UPDATE SET target.HoursWorked = source.TotalHours, target.Comments = source.Comments, target.ClientID = source.ClientID, target.BillableType = source.BillableType, target.EndTime = source.EndTime
    WHEN NOT MATCHED THEN
        INSERT (ConsultantID, [Date], [DayOfWeek], ClientID, [Description], BillableType, Comments, HoursWorked, StartTime, EndTime)
        VALUES (source.ConsultantID, source.[Date], source.DayOfWeek, source.ClientID, source.[Description], source.BillableType, source.Comments, source.TotalHours, source.StartTime, source.EndTime)
    OUTPUT $action INTO @TimesheetActions;

    SELECT @TS_Inserts = COUNT(*) FROM @TimesheetActions WHERE ActionTaken = 'INSERT';
    SELECT @TS_Updates = COUNT(*) FROM @TimesheetActions WHERE ActionTaken = 'UPDATE';
    SET @EndTimeTS = SYSDATETIME();

    -- 3. LEAVE MERGE
    SET @StartTimeLV = SYSDATETIME();
    DECLARE @LeaveActions TABLE (ActionTaken VARCHAR(20));
    DECLARE @TargetYear VARCHAR(4) = '2026';

    MERGE dbo.Leave AS target
    USING (
        SELECT 
            ISNULL(c.ConsultantID, @DefaultConsultantID) AS ConsultantID, s.LeaveType,
            TRY_CAST(s.StartDate + '-' + @TargetYear AS DATE) AS StartDate,
            ISNULL(MAX(CASE WHEN s.EndDate IS NULL OR TRIM(s.EndDate) = '' THEN TRY_CAST(s.StartDate + '-' + @TargetYear AS DATE) ELSE TRY_CAST(s.EndDate + '-' + @TargetYear AS DATE) END), TRY_CAST(s.StartDate + '-' + @TargetYear AS DATE)) AS EndDate,
            ISNULL(MAX(TRY_CAST(s.NumberOfDays AS INT)), 1) AS NumberOfDays
        FROM stg.Leave s
        LEFT JOIN dbo.Consultant c ON (TRIM(s.ConsultantFirstName) = TRIM(c.FirstName) AND TRIM(s.ConsultantLastName) = TRIM(c.LastName)) OR (c.FirstName + ' ' + c.LastName = TRIM(s.ConsultantFirstName))
        WHERE s.StartDate IS NOT NULL AND s.LeaveType IS NOT NULL AND TRY_CAST(s.StartDate + '-' + @TargetYear AS DATE) IS NOT NULL
        GROUP BY c.ConsultantID, s.LeaveType, TRY_CAST(s.StartDate + '-' + @TargetYear AS DATE)
    ) AS source
    ON (target.ConsultantID = source.ConsultantID AND target.StartDate = source.StartDate AND target.LeaveType = source.LeaveType)
    WHEN MATCHED AND source.EndDate IS NOT NULL AND (target.NumberOfDays != source.NumberOfDays OR target.EndDate != source.EndDate) THEN
        UPDATE SET target.EndDate = source.EndDate, target.NumberOfDays = source.NumberOfDays
    WHEN NOT MATCHED THEN
        INSERT (ConsultantID, LeaveType, StartDate, EndDate, NumberOfDays)
        VALUES (source.ConsultantID, source.LeaveType, source.StartDate, source.EndDate, source.NumberOfDays)
    OUTPUT $action INTO @LeaveActions;

    SELECT @LV_Inserts = COUNT(*) FROM @LeaveActions WHERE ActionTaken = 'INSERT';
    SELECT @LV_Updates = COUNT(*) FROM @LeaveActions WHERE ActionTaken = 'UPDATE';
    SET @EndTimeLV = SYSDATETIME();

    -- 4. WRITE TARGET SEGMENTATION LOGS (Now fully logged but safely capped)
    INSERT INTO dbo.AuditLog (RunNumber, LogSource, TaskName, LogStatus, RowsInserted, RowsUpdated, RowsDeleted, ExecutedBy, TargetTable, ExecutionDurationMs)
    VALUES (
        @CurrentRunNumber, @CurrentFilePath, @SSISTaskName, 'SUCCESS', 
        @TS_Inserts, @TS_Updates, 0, @ExecutionUser, 'dbo.Timesheet', DATEDIFF(MILLISECOND, @StartTimeTS, @EndTimeTS)
    );

    INSERT INTO dbo.AuditLog (RunNumber, LogSource, TaskName, LogStatus, RowsInserted, RowsUpdated, RowsDeleted, ExecutedBy, TargetTable, ExecutionDurationMs)
    VALUES (
        @CurrentRunNumber, @CurrentFilePath, @SSISTaskName, 'SUCCESS', 
        @LV_Inserts, @LV_Updates, 0, @ExecutionUser, 'dbo.Leave', DATEDIFF(MILLISECOND, @StartTimeLV, @EndTimeLV)
    );
END;
GO