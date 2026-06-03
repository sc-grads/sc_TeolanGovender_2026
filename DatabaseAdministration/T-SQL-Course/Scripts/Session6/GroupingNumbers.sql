with Numbers as (
select top(select max(EmpNumber) from tblTransaction) row_Number() over(order by (select null)) as RowNumber
from tblTransaction as U),
Transactions2014 as (
select * from tblTransaction where DateOfTransaction>='2014-01-01' and DateOfTransaction < '2015-01-01'),
tblGap as (
select U.RowNumber, 
       RowNumber - LAG(RowNumber) over(order by RowNumber) as PreviousRowNumber, 
	   LEAD(RowNumber) over(order by RowNumber) - RowNumber as NextRowNumber,
	   case when RowNumber - LAG(RowNumber) over(order by RowNumber) = 1 then 0 else 1 end as GroupGap
from Numbers as U
left join Transactions2014 as T
on U.RowNumber = T.EmpNumber
where T.EmpNumber is null),
tblGroup as (
select *, sum(GroupGap) over (ORDER BY RowNumber) as TheGroup
from tblGap)
select Min(RowNumber) as StartingEmpNumber, Max(RowNumber) as EndingEmpNumber,
       Max(RowNumber) - Min(RowNumber) + 1 as NumberEmployees
from tblGroup
group by TheGroup
order by TheGroup
