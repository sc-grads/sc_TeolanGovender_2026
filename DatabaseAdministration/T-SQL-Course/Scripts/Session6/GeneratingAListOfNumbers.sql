select E.EmpNumber from tblEmployee as E 
left join tblTransaction as T
on E.EmpNumber = T.EmpNumber
where T.EmpNumber IS NULL
order by E.EmpNumber

select max(EmpNumber) from tblTransaction;

with Numbers as (
select top(select max(EmpNumber) from tblTransaction) row_Number() over(order by (select null)) as RowNumber
from tblTransaction as U)

select U.RowNumber from Numbers as U
left join tblTransaction as T
on U.RowNumber = T.EmpNumber
where T.EmpNumber is null
order by U.RowNumber

select row_number() over(order by(select null)) from sys.objects O cross join sys.objects P