create proc NameEmployees as
begin
	select EmpNumber, EmpFirstName, EmpLastName
	from tblEmployee
end
go
NameEmployees
execute NameEmployees
exec NameEmployees

--------------------------

--Ask for a specific employee
--if exists (select * from sys.procedures where name='NameEmployees')
if object_ID('NameEmployees','P') IS NOT NULL
drop proc NameEmployees
go
create proc NameEmployees(@EmpNumber int) as
begin
	if exists (Select * from tblEmployee where EmpNumber = @EmpNumber)
	begin
		select EmpNumber, EmployeeFirstName, EmployeeLastName
		from tblEmployee
		where EmpNumber = @EmpNumber
	end
end
go
NameEmployees 4
execute NameEmployees 223
exec NameEmployees 323
select EmpNumber from NameEmployees

DECLARE @EmployeeName int = 123
select @EmployeeName
