USE TimesheetTGDB;

Truncate table dbo.Timesheet
Truncate table dbo.Leave
Truncate table stg.Timesheet
Truncate table stg.Leave
DELETE FROM dbo.Client;
DELETE FROM dbo.Consultant;
DBCC CHECKIDENT ('dbo.Client', RESEED, 0);
DBCC CHECKIDENT ('dbo.Consultant', RESEED, 0);



--Truncate table AuditLog