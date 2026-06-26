USE TimesheetDb
SELECT * FROM Timesheet
SELECT * FROM Consultant
SELECT * FROM Leave
SELECT * FROM AuditLog
SELECT * FROM Timesheet_History
SELECT * FROM Leave_History


SELECT *
FROM dbo.Timesheet t
INNER JOIN dbo.Consultant c 
    ON t.ConsultantID = c.ConsultantID
WHERE c.FirstName IN ('Rushil')
ORDER BY c.FirstName, t.[Date];

SELECT *
FROM dbo.Leave l
inner JOIN dbo.Consultant c 
    ON l.ConsultantID = c.ConsultantID
--WHERE c.FirstName IN ('Teolan')
--ORDER BY c.FirstName, l.[LeaveID];