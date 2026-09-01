USE TimesheetTGDB;
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
USE TimesheetTGDB;
GO

CREATE OR ALTER PROCEDURE dbo.usp_ProcessStagingToMaster
    @CurrentFilePath VARCHAR(500) = 'Manual Execution / Unknown',
    @SSISTaskName VARCHAR(200) = 'Stored Procedure Execution',
    @PackageRunNumber INT = NULL 
AS
BEGIN
    SET NOCOUNT ON;

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
    DECLARE @TS_Inserts INT = 0, @TS_Updates INT = 0, @TS_Deletes INT = 0;
    DECLARE @LV_Inserts INT = 0, @LV_Updates INT = 0, @LV_Deletes INT = 0;

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
    WHEN NOT MATCHED BY SOURCE THEN
        DELETE
    OUTPUT $action INTO @TimesheetActions;

    SELECT @TS_Inserts = COUNT(*) FROM @TimesheetActions WHERE ActionTaken = 'INSERT';
    SELECT @TS_Updates = COUNT(*) FROM @TimesheetActions WHERE ActionTaken = 'UPDATE';
    SELECT @TS_Deletes = COUNT(*) FROM @TimesheetActions WHERE ActionTaken = 'DELETE';
    SET @EndTimeTS = SYSDATETIME();

    -- =========================================================================
    -- 2.5 EXTRACT & CONSOLIDATE CONSECUTIVE LEAVE FROM TIMESHEET STAGING
    -- =========================================================================
    DECLARE @TargetYear VARCHAR(4) = '2026';

    ;WITH ParsedTimesheetLeave AS (
        -- Step 1: Filter timesheet leave rows & parse dates cleanly
        SELECT 
            TRIM(t.ConsultantFirstName) AS FirstName,
            TRIM(t.ConsultantLastName) AS LastName,
            ISNULL(NULLIF(TRIM(t.[Description]), ''), 'Leave') AS LeaveType,
            ts_date.ParsedTSDate AS LeaveDate,
            CASE 
                WHEN TRY_CAST(t.TotalHours AS DECIMAL(5,2)) > 0 AND TRY_CAST(t.TotalHours AS DECIMAL(5,2)) <= 4.0 THEN 0.5
                ELSE 1.0
            END AS DayValue
        FROM stg.Timesheet t
        CROSS APPLY (
            SELECT COALESCE(
                TRY_CAST(TRIM(t.[Date]) AS DATE),
                CASE 
                    WHEN t.[Date] LIKE '%/%' THEN TRY_CONVERT(DATE, t.[Date], 101)
                    WHEN t.[Date] LIKE '%-%' AND (t.[Date] LIKE '%-2026%' OR t.[Date] LIKE '%-26%') THEN TRY_CONVERT(DATE, t.[Date], 105)
                    ELSE TRY_CAST(TRIM(t.[Date]) + '-' + @TargetYear AS DATE)
                END
            ) AS ParsedTSDate
        ) ts_date
        WHERE LOWER(t.[Description]) LIKE '%leave%'
          AND ts_date.ParsedTSDate IS NOT NULL
          -- Exclude dates covered by an existing Leave tab entry
          AND NOT EXISTS (
              SELECT 1 
              FROM stg.Leave l
              CROSS APPLY (
                  SELECT 
                      COALESCE(
                          TRY_CAST(TRIM(l.StartDate) AS DATE),
                          CASE 
                              WHEN l.StartDate LIKE '%/%' THEN TRY_CONVERT(DATE, l.StartDate, 101)
                              WHEN l.StartDate LIKE '%-%' AND (l.StartDate LIKE '%-2026%' OR l.StartDate LIKE '%-26%') THEN TRY_CONVERT(DATE, l.StartDate, 105)
                              ELSE TRY_CAST(TRIM(l.StartDate) + '-' + @TargetYear AS DATE)
                          END
                      ) AS ParsedStartDate,
                      COALESCE(
                          TRY_CAST(TRIM(l.EndDate) AS DATE),
                          CASE 
                              WHEN l.EndDate IS NULL OR TRIM(l.EndDate) = '' THEN 
                                  COALESCE(
                                      TRY_CAST(TRIM(l.StartDate) AS DATE),
                                      CASE 
                                          WHEN l.StartDate LIKE '%/%' THEN TRY_CONVERT(DATE, l.StartDate, 101)
                                          WHEN l.StartDate LIKE '%-%' AND (l.StartDate LIKE '%-2026%' OR l.StartDate LIKE '%-26%') THEN TRY_CONVERT(DATE, l.StartDate, 105)
                                          ELSE TRY_CAST(TRIM(l.StartDate) + '-' + @TargetYear AS DATE)
                                      END
                                  )
                              ELSE 
                                  CASE 
                                      WHEN l.EndDate LIKE '%/%' THEN TRY_CONVERT(DATE, l.EndDate, 101)
                                      WHEN l.EndDate LIKE '%-%' AND (l.EndDate LIKE '%-2026%' OR l.EndDate LIKE '%-26%') THEN TRY_CONVERT(DATE, l.EndDate, 105)
                                      ELSE TRY_CAST(TRIM(l.EndDate) + '-' + @TargetYear AS DATE)
                                  END
                          END
                      ) AS ParsedEndDate
              ) l_dates
              WHERE TRIM(l.ConsultantFirstName) = TRIM(t.ConsultantFirstName)
                AND TRIM(l.ConsultantLastName) = TRIM(t.ConsultantLastName)
                AND ts_date.ParsedTSDate BETWEEN l_dates.ParsedStartDate AND l_dates.ParsedEndDate
          )
    ),
    Islands AS (
        -- Step 2: Assign an island anchor to group consecutive days
        SELECT 
            FirstName,
            LastName,
            LeaveType,
            LeaveDate,
            DayValue,
            DATEADD(DAY, -ROW_NUMBER() OVER (PARTITION BY FirstName, LastName, LeaveType ORDER BY LeaveDate), LeaveDate) AS IslandGroup
        FROM ParsedTimesheetLeave
    )
    -- Step 3: Insert consolidated consecutive blocks into stg.Leave
    INSERT INTO stg.Leave (
        ConsultantFirstName,
        ConsultantLastName,
        LeaveType,
        StartDate,
        EndDate,
        NumberOfDays
    )
    SELECT 
        FirstName,
        LastName,
        LeaveType,
        CONVERT(VARCHAR(10), MIN(LeaveDate), 120) AS StartDate,
        CONVERT(VARCHAR(10), MAX(LeaveDate), 120) AS EndDate,
        CAST(SUM(DayValue) AS VARCHAR(10)) AS NumberOfDays
    FROM Islands
    GROUP BY FirstName, LastName, LeaveType, IslandGroup;

    -- =========================================================================
    -- 3. LEAVE MERGE
    -- =========================================================================
    SET @StartTimeLV = SYSDATETIME();
    DECLARE @LeaveActions TABLE (ActionTaken VARCHAR(20));

    ;WITH CleanedLeave AS (
        SELECT 
            ISNULL(c.ConsultantID, @DefaultConsultantID) AS ConsultantID,
            TRIM(s.LeaveType) AS LeaveType,
            COALESCE(
                TRY_CAST(TRIM(s.StartDate) AS DATE),
                CASE 
                    WHEN s.StartDate LIKE '%/%' THEN TRY_CONVERT(DATE, s.StartDate, 101)
                    WHEN s.StartDate LIKE '%-%' AND (s.StartDate LIKE '%-2026%' OR s.StartDate LIKE '%-26%') THEN TRY_CONVERT(DATE, s.StartDate, 105)
                    ELSE TRY_CAST(TRIM(s.StartDate) + '-' + @TargetYear AS DATE)
                END
            ) AS ParsedStartDate,
            COALESCE(
                TRY_CAST(TRIM(s.EndDate) AS DATE),
                CASE 
                    WHEN s.EndDate IS NULL OR TRIM(s.EndDate) = '' THEN 
                        COALESCE(
                            TRY_CAST(TRIM(s.StartDate) AS DATE),
                            CASE 
                                WHEN s.StartDate LIKE '%/%' THEN TRY_CONVERT(DATE, s.StartDate, 101)
                                WHEN s.StartDate LIKE '%-%' AND (s.StartDate LIKE '%-2026%' OR s.StartDate LIKE '%-26%') THEN TRY_CONVERT(DATE, s.StartDate, 105)
                                ELSE TRY_CAST(TRIM(s.StartDate) + '-' + @TargetYear AS DATE)
                            END
                        )
                    ELSE 
                        CASE 
                            WHEN s.EndDate LIKE '%/%' THEN TRY_CONVERT(DATE, s.EndDate, 101)
                            WHEN s.EndDate LIKE '%-%' AND (s.EndDate LIKE '%-2026%' OR s.EndDate LIKE '%-26%') THEN TRY_CONVERT(DATE, s.EndDate, 105)
                            ELSE TRY_CAST(TRIM(s.EndDate) + '-' + @TargetYear AS DATE)
                        END
                END
            ) AS ParsedEndDate,
            CASE 
                WHEN LOWER(TRIM(s.NumberOfDays)) = 'half day' THEN 0.5
                ELSE ISNULL(TRY_CAST(TRIM(s.NumberOfDays) AS DECIMAL(4,1)), 1.0)
            END AS ParsedDays
        FROM stg.Leave s
        LEFT JOIN dbo.Consultant c ON (TRIM(s.ConsultantFirstName) = TRIM(c.FirstName) AND TRIM(s.ConsultantLastName) = TRIM(c.LastName)) 
                                   OR (c.FirstName + ' ' + c.LastName = TRIM(s.ConsultantFirstName))
        WHERE s.StartDate IS NOT NULL AND s.LeaveType IS NOT NULL
    )
    MERGE dbo.Leave AS target
    USING (
        SELECT 
            ConsultantID, LeaveType, ParsedStartDate AS StartDate, MAX(ParsedEndDate) AS EndDate, MAX(ParsedDays) AS NumberOfDays
        FROM CleanedLeave
        WHERE ParsedStartDate IS NOT NULL 
        GROUP BY ConsultantID, LeaveType, ParsedStartDate
    ) AS source
    ON (target.ConsultantID = source.ConsultantID AND target.StartDate = source.StartDate AND target.LeaveType = source.LeaveType)
    WHEN MATCHED AND (target.NumberOfDays != source.NumberOfDays OR target.EndDate != source.EndDate) THEN
        UPDATE SET target.EndDate = source.EndDate, target.NumberOfDays = source.NumberOfDays
    WHEN NOT MATCHED THEN
        INSERT (ConsultantID, LeaveType, StartDate, EndDate, NumberOfDays)
        VALUES (source.ConsultantID, source.LeaveType, source.StartDate, source.EndDate, source.NumberOfDays)
    WHEN NOT MATCHED BY SOURCE THEN
        DELETE
    OUTPUT $action INTO @LeaveActions;

    SELECT @LV_Inserts = COUNT(*) FROM @LeaveActions WHERE ActionTaken = 'INSERT';
    SELECT @LV_Updates = COUNT(*) FROM @LeaveActions WHERE ActionTaken = 'UPDATE';
    SELECT @LV_Deletes = COUNT(*) FROM @LeaveActions WHERE ActionTaken = 'DELETE';
    SET @EndTimeLV = SYSDATETIME();

    -- 4. CONDITIONAL LOGGING
    IF (@TS_Inserts + @TS_Updates + @TS_Deletes > 0)
    BEGIN
        INSERT INTO dbo.AuditLog (RunNumber, LogSource, TaskName, LogStatus, RowsInserted, RowsUpdated, RowsDeleted, ExecutedBy, TargetTable, ExecutionDurationMs)
        VALUES (
            @CurrentRunNumber, @CurrentFilePath, @SSISTaskName, 'SUCCESS', 
            @TS_Inserts, @TS_Updates, @TS_Deletes, @ExecutionUser, 'dbo.Timesheet', DATEDIFF(MILLISECOND, @StartTimeTS, @EndTimeTS)
        );
    END;

    IF (@LV_Inserts + @LV_Updates + @LV_Deletes > 0)
    BEGIN
        INSERT INTO dbo.AuditLog (RunNumber, LogSource, TaskName, LogStatus, RowsInserted, RowsUpdated, RowsDeleted, ExecutedBy, TargetTable, ExecutionDurationMs)
        VALUES (
            @CurrentRunNumber, @CurrentFilePath, @SSISTaskName, 'SUCCESS', 
            @LV_Inserts, @LV_Updates, @LV_Deletes, @ExecutionUser, 'dbo.Leave', DATEDIFF(MILLISECOND, @StartTimeLV, @EndTimeLV)
        );
    END;
END;
GO