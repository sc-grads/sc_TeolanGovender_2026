begin tran
alter table tblEmployee
add Manager int
go
update tblEmployee
set Manager = ((EmpNumber-123)/10)+123
where EmpNumber>123
select E.EmpNumber, E.EmpFirstName, E.EmpLastName,
       M.EmpNumber as ManagerNumber, M.EmpFirstName as ManagerFirstName, 
	   M.EmpLastName as ManagerLastName
from tblEmployee as E
left JOIN tblEmployee as M
on E.Manager = M.EmpNumber

rollback tran
