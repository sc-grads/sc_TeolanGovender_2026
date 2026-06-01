-- Check if stored procedure exists, then drop it (safe recreate pattern)
-- (modern approach using object_ID)
if object_ID('AverageBalance','P') IS NOT NULL
drop proc AverageBalance
go


-- Create stored procedure to calculate average balance per employee range
-- INPUT: employee number range
-- OUTPUT: average balance across those employees
create proc AverageBalance(
    @EmpNumberFrom int, 
    @EmpNumberTo int, 
    @AverageBalance int OUTPUT
) as
begin

    -- avoids extra "rows affected" messages
	SET NOCOUNT ON

    -- variables to store intermediate calculations
	declare @TotalAmount money
	declare @NumOfEmployee int

    -- error handling block (protects against runtime errors like divide-by-zero)
	begin try

        -- sum of all transaction amounts in employee range
		select @TotalAmount = sum(Amount) 
        from tblTransaction
		where EmpNumber between @EmpNumberFrom and @EmpNumberTo

        -- number of distinct employees in that range
		select @NumOfEmployee = count(distinct EmpNumber) 
        from tblEmployee
		where EmpNumber between @EmpNumberFrom and @EmpNumberTo

        -- calculate average balance (can fail if @NumOfEmployee = 0)
		set @AverageBalance = @TotalAmount / @NumOfEmployee

        -- success status
		RETURN 0

	end try

	begin catch

        -- fallback value when an error occurs
		set @AverageBalance = 0

        -- return detailed error diagnostics for debugging
		SELECT 
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() as ErrorLine,
            ERROR_NUMBER() as ErrorNumber,
            ERROR_PROCEDURE() as ErrorProcedure,
            ERROR_SEVERITY() as ErrorSeverity,  -- severity scale (info to critical)
            ERROR_STATE() as ErrorState

        -- failure status
		RETURN 1

	end catch
end
go


-- Execute procedure (normal small range)
DECLARE @AvgBalance int, @ReturnStatus int
EXEC @ReturnStatus = AverageBalance 4, 5, @AvgBalance OUTPUT
select @AvgBalance as Average_Balance, @ReturnStatus as Return_Status
GO


-- Execute procedure (larger range, more data involved)
DECLARE @AvgBalance int, @ReturnStatus int
execute @ReturnStatus = AverageBalance 223, 227, @AvgBalance OUTPUT
select @AvgBalance as Average_Balance, @ReturnStatus as Return_Status
GO


-- Execute procedure using named parameters (clearer + safer)
DECLARE @AvgBalance int, @ReturnStatus int
exec @ReturnStatus = AverageBalance 
    @EmpNumberFrom = 323, 
    @EmpNumberTo = 327, 
    @AverageBalance = @AvgBalance OUTPUT

select @AvgBalance as Average_Balance, @ReturnStatus as Return_Status


-- Example of conversion error (invalid string to int)
SELECT TRY_CONVERT(int, 'two')