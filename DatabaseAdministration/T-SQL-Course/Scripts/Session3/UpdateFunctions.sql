-- Create/alter a trigger on tblTransaction
ALTER TRIGGER TR_tblTransaction
ON tblTransaction
AFTER DELETE, INSERT, UPDATE
AS
BEGIN
	-- Only run if rows were affected
	IF @@ROWCOUNT > 0
	BEGIN
		-- Shows new rows after INSERT/UPDATE
		select * from Inserted

		-- Shows old rows before DELETE/UPDATE
		select * from Deleted
	END
END
GO

-- Insert a new transaction
insert into tblTransaction(Amount, DateOfTransaction, EmpNumber)
VALUES (123,'2015-07-11', 123)

-- View specific data from the view
SELECT * FROM ViewByDepartment 
where TotalAmount = -2.77 and EmpNumber = 132

-- Start a transaction
begin tran

-- Delete rows through the view
delete from ViewByDepartment
where TotalAmount = -2.77 and EmpNumber = 132

-- Undo the delete
rollback tran

-- Recreate trigger with UPDATE checking
ALTER TRIGGER TR_tblTransaction
ON tblTransaction
AFTER DELETE, INSERT, UPDATE
AS
BEGIN
	-- Returns bitmask of updated columns
	--SELECT COLUMNS_UPDATED()

	-- Runs only if Amount column was updated
	IF UPDATE(Amount) -- if (COLUMNS_UPDATED() & POWER(2,1-1)) > 0
	BEGIN
		-- New values after update
		select * from Inserted

		-- Old values before update
		select * from Deleted
	END
END
go

-- Start transaction
begin tran

--SELECT * FROM ViewByDepartment where TotalAmount = -2.77 and EmpNumber = 132

-- Update rows through the view
update ViewByDepartment
set TotalAmount = +2.77
where TotalAmount = -2.77 and EmpNumber = 132

-- Undo the update
rollback tran