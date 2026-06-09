IF OBJECT_ID('DeploymentLogs') IS NULL
BEGIN
    CREATE TABLE DeploymentLogs (
        Id INT IDENTITY PRIMARY KEY,
        RunTime DATETIME DEFAULT GETDATE(),
        Status NVARCHAR(50),
        Message NVARCHAR(255)
    );
END