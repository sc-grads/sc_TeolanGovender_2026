SELECT * 
from dbo.TransactionList(123)
GO

select *, (select count(*) from dbo.TransactionList(E.EmpNumber)) as NumTransactions
from tblEmployee as E

select *
from tblEmployee as E
outer apply TransactionList(E.EmpNumber) as T

select *
from tblEmployee as E
cross apply TransactionList(E.EmpNumber) as T

--123 left join TransactionList(123)
--124 left join TransactionList(124)

--outer apply all of tblEmployee, UDF 0+ rows
--cross apply UDF 1+ rows

--outer apply = LEFT JOIN
--cross apply = INNER JOIN

select *
from tblEmployee as E
where  (select count(*) from dbo.TransactionList(E.EmpNumber)) >3
