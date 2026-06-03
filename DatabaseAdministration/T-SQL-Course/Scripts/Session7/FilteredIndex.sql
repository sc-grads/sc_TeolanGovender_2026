CREATE NONCLUSTERED INDEX idx_tblEmployee_Employee  
    ON dbo.tblEmployee(EmpNumber) where EmpNumber<139; --we filtered down the index to where EmpNumber is less than 139

SELECT EmpNumber, EmpFirstName
FROM tblEmployee
where EmpNumber<139