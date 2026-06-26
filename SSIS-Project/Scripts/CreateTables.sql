USE TimesheetDb

IF OBJECT_ID('dbo.Timesheet', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Timesheet (
        TimesheetEntryID INT IDENTITY(1,1) PRIMARY KEY,
        ConsultantID INT FOREIGN KEY REFERENCES Consultant(ConsultantID),
        [Date] NVARCHAR(255),
        [D of Week] NVARCHAR(255),
        Client NVARCHAR(255),
        --ClientProjectName NVARCHAR(255),
        Description NVARCHAR(255),
        BillableType NVARCHAR(255),
        Comments NVARCHAR(255),
        TotalHours NVARCHAR(255),
        StartTime NVARCHAR(255),
        EndTime NVARCHAR(255)
    );
END

IF OBJECT_ID('dbo.Consultant', 'U') IS NULL
BEGIN
CREATE TABLE Consultant (
    ConsultantID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL CONSTRAINT UC_ConsultantName UNIQUE
);
END

IF OBJECT_ID('dbo.Leave', 'U') IS NULL
BEGIN
CREATE TABLE dbo.Leave (
    LeaveID INT IDENTITY(1,1) PRIMARY KEY,
    ConsultantID INT NOT NULL,
    LeaveType NVARCHAR(255) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    NumberOfDays INT NOT NULL,
    CONSTRAINT FK_Leave_Consultant FOREIGN KEY (ConsultantID) 
        REFERENCES dbo.Consultant (ConsultantID)
);
END

IF OBJECT_ID('dbo.AuditLog', 'U') IS NULL
BEGIN
CREATE TABLE dbo.AuditLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    LogDateTime DATETIME DEFAULT GETDATE(),
    RunNumber INT,                 -- Tracks "Run 1", "Run 2", etc.
    FilePath VARCHAR(250),        
    TaskName VARCHAR(100),        
    LogStatus VARCHAR(50),        
    RowsInserted INT DEFAULT 0,
    RowsUpdated INT DEFAULT 0
);
END

IF OBJECT_ID('dbo.Timesheet_History', 'U') IS NULL
BEGIN
CREATE TABLE dbo.Timesheet_History (
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    ArchiveDateTime DATETIME DEFAULT GETDATE(),
    RunNumber INT,
    ConsultantID INT,
    [Date] NVARCHAR(255),
    [D of Week] NVARCHAR(255),
    Client NVARCHAR(255),
    --ClientProjectName NVARCHAR(255),
    Description NVARCHAR(255),
    BillableType NVARCHAR(255),
    Comments NVARCHAR(255),
    TotalHours NVARCHAR(255),
    StartTime NVARCHAR(255),
    EndTime NVARCHAR(255)
);
END

IF OBJECT_ID('dbo.Leave_History', 'U') IS NULL
BEGIN
CREATE TABLE dbo.Leave_History (
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    ArchiveDateTime DATETIME DEFAULT GETDATE(),
    RunNumber INT,
    ConsultantID INT,
    LeaveType NVARCHAR(255),
    StartDate DATE,
    EndDate DATE,
    NumberOfDays INT
);
END