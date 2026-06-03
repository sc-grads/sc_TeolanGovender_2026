select *
into dbo.tblTransactionBig
from [dbo].[tblTransaction]

insert into dbo.tblTransactionBig ([Amount], [DateOfTransaction], [EmpNumber])
select T1.Amount, T2.DateOfTransaction, 1 as EmpNumber
from [dbo].[tblTransaction] as T1
cross join (select * from [dbo].[tblTransaction] where EmpNumber<200) as T2

create nonclustered index idx_tbltblTransactionBig on dbo.tblTransactionBig(EmpNumber)

create proc procTransactionBig(@EmpNumber as int) WITH RECOMPILE
as
select *
from tblTransactionBig as T
left join tblEmployee as E
on T.EmpNumber = E.EmpNumber
where T.EmpNumber = @EmpNumber

exec procTransactionBig 1
exec procTransactionBig 132
