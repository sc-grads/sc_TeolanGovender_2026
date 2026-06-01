--if exists (select * from sys.procedures where name='NameEmployees')
if object_ID('NameEmployees','P') IS NOT NULL
drop proc NameEmployees
go
create proc NameEmployees(@EmpNumberFrom int, @EmpNumberTo int) as
begin
	if exists (Select * from tblEmployee where EmpNumber between @EmpNumberFrom and @EmpNumberTo)
	begin
		declare @EmpNumber int = @EmpNumberFrom
		while @EmpNumber <= @EmpNumberTo
		BEGIN
			if exists (Select * from tblEmployee where EmpNumber = @EmpNumber)
			select EmpNumber, EmpFirstName, EmpLastName
			from tblEmployee
			where EmpNumber = @EmpNumber
			SET @EmpNumber = @EmpNumber + 1
		END
	end
end
go
NameEmployees 4, 5
execute NameEmployees 223, 227
exec NameEmployees @EmpNumberFrom = 323, @EmpNumberTo = 1327
