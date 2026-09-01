USE TimesheetTGDB

SELECT * FROM dbo.Timesheet
SELECT * FROM Consultant
SELECT * FROM Leave
SELECT * FROM Client
SELECT * FROM AuditLog
SELECT * FROM stg.Timesheet
SELECT * FROM stg.Leave

SELECT *
FROM dbo.Timesheet t
INNER JOIN dbo.Consultant c 
    ON t.ConsultantID = c.ConsultantID
WHERE c.FirstName IN ('teolan')
ORDER BY c.FirstName, t.[Date];

SELECT *
FROM dbo.Leave l
inner JOIN dbo.Consultant c 
    ON l.ConsultantID = c.ConsultantID
--WHERE c.FirstName IN ('Teolan')
--ORDER BY c.FirstName, l.[LeaveID];