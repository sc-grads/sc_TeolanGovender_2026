-- Check if stored procedure exists, then drop it (safe recreation pattern)
-- (older style commented out sys.procedures check)
-- if exists (select * from sys.procedures where name='NameEmployees')
if object_ID('NameEmployees','P') IS NOT NULL
drop proc NameEmployees
go


-- Create stored procedure with:
-- input parameters: range of employee numbers
-- output parameter: returns number of rows found
-- return value: status code (0 = success, 1 = no rows found)
create proc NameEmployees(
    @EmpNumberFrom int, 
    @EmpNumberTo int, 
    @NumberOfRows int OUTPUT
) as
begin

    -- check if any employees exist in the given range
	if exists (Select * from tblEmployee 
               where EmpNumber between @EmpNumberFrom and @EmpNumberTo)
	begin

        -- return matching employees
		select EmpNumber, EmpFirstName, EmpLastName
		from tblEmployee
		where EmpNumber between @EmpNumberFrom and @EmpNumberTo

        -- capture number of rows returned by SELECT
		SET @NumberOfRows = @@ROWCOUNT

        -- indicate success
		RETURN 0
	end
	ELSE
	BEGIN
        -- no rows found, explicitly set output to 0
	    SET @NumberOfRows = 0

        -- indicate failure / no data
		RETURN 1
	END
end
go


-- Call procedure (positional parameters)
-- captures return status + output row count
DECLARE @NumberRows int, @ReturnStatus int
EXEC @ReturnStatus = NameEmployees 4, 5, @NumberRows OUTPUT
select @NumberRows as MyRowCount, @ReturnStatus as Return_Status
GO


-- Call procedure with range that likely returns multiple rows
DECLARE @NumberRows int, @ReturnStatus int
execute @ReturnStatus = NameEmployees 4, 327, @NumberRows OUTPUT
select @NumberRows as MyRowCount, @ReturnStatus as Return_Status
GO


-- Call procedure using named parameters (more readable)
DECLARE @NumberRows int, @ReturnStatus int
exec @ReturnStatus = NameEmployees 
    @EmpNumberFrom = 323, 
    @EmpNumberTo = 327, 
    @NumberOfRows = @NumberRows OUTPUT

-- show output value + return status code
select @NumberRows as MyRowCount, @ReturnStatus as Return_Status