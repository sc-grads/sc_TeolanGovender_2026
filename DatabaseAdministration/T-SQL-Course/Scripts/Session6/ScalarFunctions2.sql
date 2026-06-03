if object_ID(N'NumberOfTransactions',N'FN') IS NOT NULL
	DROP FUNCTION NumberOfTransactions
GO
CREATE FUNCTION NumberOfTransactions(@EmpNumber int)
RETURNS int
AS
BEGIN
	DECLARE @NumberOfTransactions INT
	SELECT @NumberOfTransactions = COUNT(*) FROM tblTransaction
	WHERE EmpNumber = @EmpNumber
	RETURN @NumberOfTransactions
END


SELECT *, dbo.NumberOfTransactions(EmpNumber) as TransNumber
FROM tblEmployee