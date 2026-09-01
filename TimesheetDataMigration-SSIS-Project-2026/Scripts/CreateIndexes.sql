USE TimesheetTGDB;
GO

-- 1. INDEXES FOR TABLE: dbo.Consultant
-- Accelerate the Consultant lookup joins on name matching
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Consultant_Names' AND object_id = OBJECT_ID('dbo.Consultant'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Consultant_Names 
    ON dbo.Consultant (FirstName, LastName) 
    INCLUDE (ConsultantID);
END
GO


-- 2. INDEXES FOR TABLE: dbo.Timesheet
-- High-performance composite index for the Timesheet MERGE engine matching
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Timesheet_MergeIdentity' AND object_id = OBJECT_ID('dbo.Timesheet'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Timesheet_MergeIdentity 
    ON dbo.Timesheet (ConsultantID, [Date], StartTime)
    INCLUDE ([Description], HoursWorked, Comments, ClientID, BillableType, EndTime);
END
GO


-- 3. INDEXES FOR TABLE: dbo.Leave
-- High-performance composite index for Leave pipeline matching
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Leave_MergeIdentity' AND object_id = OBJECT_ID('dbo.Leave'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Leave_MergeIdentity 
    ON dbo.Leave (ConsultantID, StartDate, LeaveType)
    INCLUDE (EndDate, NumberOfDays);
END
GO