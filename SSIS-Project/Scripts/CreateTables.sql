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

--Production Timesheet Table
IF OBJECT_ID('dbo.Timesheet', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Timesheet (
        TimesheetEntryID INT IDENTITY(1,1) PRIMARY KEY,
        ConsultantID INT NOT NULL FOREIGN KEY REFERENCES dbo.Consultant(ConsultantID),
        [Date] DATE NOT NULL,
        [DayOfWeek] VARCHAR(20),
        Client VARCHAR(150),
        [Description] VARCHAR(255),
        BillableType VARCHAR(50),
        Comments VARCHAR(500),
        TotalHours DECIMAL(5,2) NOT NULL,
        StartTime TIME,
        EndTime TIME,
        CONSTRAINT UC_Timesheet_Key UNIQUE (ConsultantID, [Date], [Description], StartTime)
    );
    CREATE NONCLUSTERED INDEX IX_Timesheet_ConsultantDate ON dbo.Timesheet(ConsultantID, [Date]);
END

--Production Leave Table
IF OBJECT_ID('dbo.Leave', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Leave (
        LeaveID INT IDENTITY(1,1) PRIMARY KEY,
        ConsultantID INT NOT NULL FOREIGN KEY REFERENCES dbo.Consultant(ConsultantID),
        LeaveType VARCHAR(100) NOT NULL,
        StartDate DATE NOT NULL,
        EndDate DATE NOT NULL,
        NumberOfDays INT NOT NULL,
        CONSTRAINT UC_Leave_Key UNIQUE (ConsultantID, StartDate, LeaveType)
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

-- Audit Log Table
IF OBJECT_ID('dbo.AuditLog', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AuditLog (
        LogID INT IDENTITY(1,1) PRIMARY KEY,
        LogDateTime DATETIME DEFAULT GETDATE(),
        RunNumber INT,
        FilePath VARCHAR(250),        
        TaskName VARCHAR(100),        
        LogStatus VARCHAR(50),        
        RowsInserted INT DEFAULT 0,
        RowsUpdated INT DEFAULT 0,
        RowsDeleted INT DEFAULT 0
    );
END


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