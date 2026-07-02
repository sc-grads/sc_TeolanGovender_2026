USE TimesheetDb;
GO


--MASTER TABLES (Production Data Store)
IF OBJECT_ID('dbo.Consultant', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Consultant (
        ConsultantID INT IDENTITY(1,1) PRIMARY KEY,
        FirstName VARCHAR(100) NOT NULL,
        LastName VARCHAR(100) NOT NULL,
        CONSTRAINT UC_Consultant_FullName UNIQUE (FirstName, LastName)
    );
END


-- Create Master Client table
IF OBJECT_ID('dbo.Client', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Client (
        ClientID INT IDENTITY(1,1) CONSTRAINT PK_Client PRIMARY KEY,
        ClientName VARCHAR(100) NOT NULL CONSTRAINT UC_Client_Name UNIQUE
    );
END
GO


--Production Timesheet Table
USE TimesheetDb;
GO

IF OBJECT_ID('dbo.Timesheet', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Timesheet (
        TimesheetEntryID INT IDENTITY(1,1) CONSTRAINT PK_Timesheet PRIMARY KEY,
        ConsultantID INT NOT NULL CONSTRAINT FK_Timesheet_Consultant FOREIGN KEY REFERENCES dbo.Consultant(ConsultantID),
        ClientID INT NOT NULL CONSTRAINT FK_Timesheet_Client FOREIGN KEY REFERENCES dbo.Client(ClientID), -- New Master Relationship Key
        [Date] DATE NOT NULL,
        [DayOfWeek] VARCHAR(20),
        [Description] VARCHAR(255),
        BillableType VARCHAR(50),
        Comments VARCHAR(500),
        HoursWorked DECIMAL(5,2) NOT NULL,
        StartTime TIME(0), -- Matches standard storage format precision
        EndTime TIME(0),   -- Matches standard storage format precision
        CONSTRAINT UC_Timesheet_Key UNIQUE (ConsultantID, [Date], [Description], StartTime)
    );

    -- Composite index to optimize lookups on core operational queries
    CREATE NONCLUSTERED INDEX IX_Timesheet_ConsultantDate 
    ON dbo.Timesheet(ConsultantID, [Date]);
END
GO


-- Production Leave Table
IF OBJECT_ID('dbo.Leave', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Leave (
        LeaveEntryID INT IDENTITY(1,1) PRIMARY KEY,
        ConsultantID INT NOT NULL FOREIGN KEY REFERENCES dbo.Consultant(ConsultantID),
        LeaveType VARCHAR(100) NOT NULL,
        StartDate DATE NOT NULL,
        EndDate DATE NOT NULL,
        NumberOfDays DECIMAL(4,1) NOT NULL, -- Changed from INT to DECIMAL to support 0.5 entries
        CONSTRAINT UC_Leave_Key UNIQUE (ConsultantID, StartDate, LeaveType)
    );
END
GO


-- Audit Log Table
IF OBJECT_ID('dbo.AuditLog', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AuditLog (
        LogID INT IDENTITY(1,1) CONSTRAINT PK_AuditLog PRIMARY KEY,
        LogDateTime DATETIME CONSTRAINT DF_AuditLog_LogDateTime DEFAULT GETDATE(),
        RunNumber INT NOT NULL,
        LogSource VARCHAR(500),        
        TaskName VARCHAR(200),        
        LogStatus VARCHAR(50),        
        RowsInserted INT CONSTRAINT DF_AuditLog_RowsInserted DEFAULT 0,
        RowsUpdated INT CONSTRAINT DF_AuditLog_RowsUpdated DEFAULT 0,
        RowsDeleted INT CONSTRAINT DF_AuditLog_RowsDeleted DEFAULT 0,
        ExecutedBy VARCHAR(100),       -- Tracks local or system user domain context
        TargetTable VARCHAR(50),       -- Segments metrics out by destination table
        ExecutionDurationMs INT        -- Captures engine processing runtime performance
    );
END
GO


--STAGING TABLES
-- Check if the schema does not exist, then create it using dynamic SQL
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg')
BEGIN
    EXEC('CREATE SCHEMA stg;');
END
GO

-- Drop/Recreate staging tables to guarantee a clean slate structure
DROP TABLE IF EXISTS stg.Timesheet;
CREATE TABLE stg.Timesheet (
    ConsultantFirstName NVARCHAR(100),
    ConsultantLastName NVARCHAR(100),
    [Date] NVARCHAR(255),
    [DayOfWeek] NVARCHAR(255),
    Client NVARCHAR(255),
    [Description] NVARCHAR(255),
    BillableType NVARCHAR(255),
    Comments NVARCHAR(255),
    TotalHours NVARCHAR(255),
    StartTime NVARCHAR(255),
    EndTime NVARCHAR(255)
);

DROP TABLE IF EXISTS stg.Leave;
CREATE TABLE stg.Leave (
    ConsultantFirstName NVARCHAR(100),
    ConsultantLastName NVARCHAR(100),
    LeaveType NVARCHAR(255),
    StartDate NVARCHAR(255),
    EndDate NVARCHAR(255),
    NumberOfDays NVARCHAR(255)
);