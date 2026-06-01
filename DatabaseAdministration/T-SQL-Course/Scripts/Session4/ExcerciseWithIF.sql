--if exists (select * from sys.procedures where name='NameEmployees')
if object_ID('NameEmployees','P') IS NOT NULL
drop proc NameEmployees
go
create proc NameEmployees(@EmpNumber int) as
begin
	if exists (Select * from tblEmployee where EmpNumber = @EmpNumber)
	begin
		if @EmpNumber < 300
		begin
			select EmpNumber, EmpFirstName, EmpLastName
			from tblEmployee
			where EmpNumber = @EmpNumber
		end
		else
		begin
			select EmpNumber, EmpFirstName, EmpLastName, Department
			from tblEmployee
			where EmpNumber = @EmpNumber			
			select * from tblTransaction where EmpNumber = @EmpNumber
		end
	end
end
go
NameEmployees 4
execute NameEmployees 223
exec NameEmployees 324
