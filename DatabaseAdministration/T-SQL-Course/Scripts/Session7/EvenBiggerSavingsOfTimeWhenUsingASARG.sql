select E.EmpNumber, T.Amount
from [dbo].[tblEmployee] as E
left join [dbo].[tblTransaction] as T
on E.EmpNumber = T.EmpNumber
where E.EmpNumber = 134

select E.EmpNumber, T.Amount
from [dbo].[tblEmployeeNoIndex] as E
left join [dbo].[tblTransactionNoIndex] as T
on E.EmpNumber = T.EmpNumber
where E.EmpNumber = 134
select E.EmpNumber, T.Amount
from [dbo].[tblEmployee] as E
left join [dbo].[tblTransaction] as T
on E.EmpNumber = T.EmpNumber
where E.EmpNumber / 10 = 34 --Not SARG

select E.EmpNumber, T.Amount
from [dbo].[tblEmployee] as E
left join [dbo].[tblTransaction] as T
on E.EmpNumber = T.EmpNumber
where E.EmpNumber between 340 and 349 --SARG
