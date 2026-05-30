
CREATE TRIGGER [TriggerName]
    ON [dbo].[TableName]
    INSTEAD OF DELETE
    AS
    BEGIN
    SET NOCOUNT ON
    END;

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
--SELECT * FROM ViewByDepartment where TotalAmount = -2.77 and EmpNumber = 132
delete from ViewByDepartment
where TotalAmount = -2.77 and EmpNumber = 132
SELECT * FROM ViewByDepartment where TotalAmount = -2.77 and EmpNumber = 132
rollback tran
