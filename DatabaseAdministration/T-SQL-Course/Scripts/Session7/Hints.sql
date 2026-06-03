select D.Department, D.DepartmentHead, E.EmpNumber, E.EmpFirstName, E.EmpLastName 
from [dbo].[tblDepartment] as D  WITH (NOLOCK)
left join [dbo].[tblEmployee] as E
on D.Department = E.Department
where D.Department = 'HR'

SET STATISTICS IO ON
GO

select D.Department, D.DepartmentHead, E.EmpNumber, E.EmpFirstName, E.EmpLastName 
from [dbo].[tblDepartment] as D  WITH (REPEATABLEREAD)
left join [dbo].[tblEmployee] as E
on D.Department = E.Department
where D.Department = 'HR'