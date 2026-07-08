USE master;
GO

IF DB_ID('TimesheetDb_tg') IS NULL
BEGIN
    CREATE DATABASE TimesheetDb_tg;

    ALTER DATABASE TimesheetDb_tg SET MULTI_USER; 
END
GO