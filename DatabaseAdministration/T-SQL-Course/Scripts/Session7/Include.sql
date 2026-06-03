CREATE NONCLUSTERED INDEX idx_tblEmployee_Employee  
ON dbo.tblEmployee(EmpNumber)
include (EmpFirstName);

DROP INDEX idx_tblEmployee_Employee ON dbo.tblEmployee

SELECT EmpFirstName
From tblEmployee
Where EmpNumber between 140 and 150