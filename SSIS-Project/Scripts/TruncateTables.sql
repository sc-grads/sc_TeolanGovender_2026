USE TimesheetDb;
DELETE FROM dbo.Timesheet;
DELETE FROM dbo.Leave;
DELETE FROM dbo.Consultant;
DBCC CHECKIDENT ('dbo.Timesheet', RESEED, 0);
DBCC CHECKIDENT ('dbo.Consultant', RESEED, 0);
DBCC CHECKIDENT ('dbo.Leave', RESEED, 0);

Truncate table AuditLog
Truncate table Timesheet_History
Truncate table Leave_History