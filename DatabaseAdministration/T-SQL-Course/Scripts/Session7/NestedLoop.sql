select D.Department, D.DepartmentHead, E.EmpNumber, E.EmpFirstName, E.EmpLastName 
from [dbo].[tblDepartment] as D
left join [dbo].[tblEmployee] as E
on D.Department = E.Department
where D.Department = 'HR'

select *
from [dbo].[tblEmployee] as E
left join [dbo].[tblTransaction] as T
on E.EmpNumber = T.EmpNumber

select E.EmpNumber, T.Amount
from [dbo].[tblEmployee] as E
left join [dbo].[tblTransaction] as T
on E.EmpNumber = T.EmpNumber
