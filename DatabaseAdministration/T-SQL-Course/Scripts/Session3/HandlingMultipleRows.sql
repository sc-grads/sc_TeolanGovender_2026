-- Bad code - only allows 1 row to be deleted

alter TRIGGER tr_ViewByDepartment
ON dbo.ViewByDepartment
INSTEAD OF DELETE
AS
BEGIN
    declare @EmpNumber as int
	declare @DateOfTransaction as smalldatetime
	declare @Amount as smallmoney
	select @EmpNumber = EmpNumber, @DateOfTransaction = DateOfTransaction,  @Amount = TotalAmount
	from deleted
	--SELECT * FROM deleted
	delete tblTransaction
	from tblTransaction as T
	where T.EmpNumber = @EmpNumber
	and T.DateOfTransaction = @DateOfTransaction
	and T.Amount = @Amount
END

begin tran
SELECT * FROM ViewByDepartment where EmpNumber = 132
delete from ViewByDepartment
where EmpNumber = 132
SELECT * FROM ViewByDepartment where EmpNumber = 132
rollback tran

-- Good code - allows multiple rows to be deleted

alter TRIGGER tr_ViewByDepartment
ON dbo.ViewByDepartment
INSTEAD OF DELETE
AS
BEGIN
	SELECT *, 'To Be Deleted' FROM deleted
       delete tblTransaction
	from tblTransaction as T
	join deleted as D
	on T.EmpNumber = D.EmpNumber
	and T.DateOfTransaction = D.DateOfTransaction
	and T.Amount = D.TotalAmount
END
GO

begin tran
SELECT *, 'Before Delete' FROM ViewByDepartment where EmpNumber = 132
delete from ViewByDepartment
where EmpNumber = 132 --and TotalAmount = 861.16
SELECT *, 'After Delete' FROM ViewByDepartment where EmpNumber = 132
rollback tran