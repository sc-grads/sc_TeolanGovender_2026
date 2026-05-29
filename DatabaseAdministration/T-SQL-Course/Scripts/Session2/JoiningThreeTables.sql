SELECT tblDepartment.Department,DepartmentHead ,sum(Amount) as SumOfAmount
FROM tblDepartment
Left join tblEmployee
on tblDepartment.Department = tblEmployee.Department
Left join tblTransaction
on tblTransaction.EmpNumber = tblEmployee.EmpNumber
group by tblDepartment.Department, DepartmentHead
Order by Department

Insert into tblDepartment(Department,DepartmentHead)
values ('Accounts','James')

SELECT D.DepartmentHead, sum(T.Amount) as SumOfAmount
from tblDepartment as D
left join tblEmployee as E
on D.Department = E.Department
left join tblTransaction T
on E.EmpNumber = T.EmpNumber
group by D.DepartmentHead
order by D.DepartmentHead