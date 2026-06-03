if object_ID(N'TransactionList',N'FN') IS NOT NULL
	DROP FUNCTION TransactionList
GO

CREATE FUNCTION TransactionList(@EmpNumber int)
RETURNS TABLE AS RETURN
(
    SELECT * FROM tblTransaction
	WHERE EmpNumber = @EmpNumber
)

SELECT * 
from dbo.TransactionList(123)

select *
from tblEmployee
where exists(select * from dbo.TransactionList(EmpNumber))

select distinct E.*
from tblEmployee as E
join tblTransaction as T
on E.EmpNumber = T.EmpNumber

select *
from tblEmployee as E
where exists(Select EmpNumber from tblTransaction as T where E.EmpNumber = T.EmpNumber)