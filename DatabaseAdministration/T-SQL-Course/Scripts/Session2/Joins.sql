--EmpNumber is written as tblEmployee.EmpNumber because it exists in the transaction table and the Employee table, EmpFirsttname is only in employee and Amount is only in transactional so it does not need tablename.cloumnname
SELECT tblEmployee.EmpNumber, EmpFirstname, EmpLastName, sum(Amount) AS SumOfAmount
FROM [dbo].[tblEmployee]
left join tblTransaction
on tblEmployee.EmpNumber = tblTransaction.EmpNumber
GROUP BY tblEmployee.EmpNumber, EmpFirstName, EmpLastName
--Having sum(Amount) = 6100.75
ORDER BY EmpNumber

SELECT * FROM tblTransaction
SELECT * FROM tblEmployee