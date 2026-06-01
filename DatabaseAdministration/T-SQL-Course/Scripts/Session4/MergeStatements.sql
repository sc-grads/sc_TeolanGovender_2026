BEGIN TRAN
MERGE INTO tblTransaction as T
USING tblTransactionNew as S
ON T.EmpNumber = S.EmpNumber AND T.DateOfTransaction = S.DateOfTransaction
WHEN MATCHED THEN
    UPDATE SET Amount = T.Amount + S.Amount
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Amount], [DateOfTransaction], [EmpNumber])
	VALUES (S.Amount, S.DateOfTransaction, S.EmpNumber);
ROLLBACK TRAN

-- tblTransaction (no) - tblTransactionNew (yes)
-- 1 tblTransaction - 1 tblTransactionNew
-- 1 tblTransaction - multiple rows TblTransactionNew

-----------------------------------------------------------------------------------------------------


--Let’s expand our MERGE statement
SELECT DateOfTransaction, EmpNumber, COUNT(*) AS NumberOfRows
FROM tblTransactionNew 
GROUP BY DateOfTransaction, EmpNumber
HAVING COUNT(*)>1

BEGIN TRAN
go
DISABLE TRIGGER TR_tblTransaction ON dbo.tblTransaction
GO
MERGE INTO tblTransaction as T
USING (SELECT DateOfTransaction, EmpNumber, MIN(Amount) as Amount
      FROM tblTransactionNew
	  GROUP BY DateOfTransaction, EmpNumber) as S
ON T.EmpNumber = S.EmpNumber AND
	T.DateOfTransaction = S.DateOfTransaction
WHEN MATCHED THEN
    UPDATE SET Amount = T.Amount + S.Amount
WHEN NOT MATCHED THEN
	INSERT (Amount, DateOfTransaction, EmpNumber)
	VALUES (S.Amount, S.DateOfTransaction, S.EmpNumber)
	OUTPUT deleted.*, inserted.*;
ROLLBACK TRAN
9. Merge with additional column
BEGIN TRAN
ALTER TABLE tblTransaction
ADD Comments varchar(50) NULL
GO -- DDL
MERGE TOP (5) PERCENT INTO tblTransaction as T --DML
USING (select EmpNumber, DateOfTransaction, sum(Amount) as Amount
from tblTransactionNew
group by EmpNumber, DateOfTransaction) as S
ON T.EmpNumber = S.EmpNumber AND T.DateOfTransaction = S.DateOfTransaction
WHEN MATCHED AND T.Amount + S.Amount >0 THEN
    UPDATE SET Amount = T.Amount + S.Amount, Comments = 'Updated Row'
WHEN MATCHED THEN
	DELETE
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Amount], [DateOfTransaction], [EmpNumber], Comments)
	VALUES (S.Amount, S.DateOfTransaction, S.EmpNumber, 'Inserted Row')
WHEN NOT MATCHED BY SOURCE THEN
	UPDATE SET Comments = 'Unchanged'
OUTPUT inserted.*, deleted.* , $action;
--Select * from tblTransaction ORDER BY EmpNumber, DateOfTransaction
ROLLBACK TRAN
