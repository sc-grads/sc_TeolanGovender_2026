select 1
go
create view ViewByDepartment as 
select D.Department, T.EmpNumber, T.DateOfTransaction, T.Amount as TotalAmount
from tblDepartment as D
left join tblEmployee as E
on D.Department = E.Department
left join tblTransaction as T
on E.EmpNumber = T.EmpNumber
where T.EmpNumber between 120 and 139
--order by D.Department, T.EmpNumber
go

create view ViewSummary as 
select D.Department, T.EmpNumber as EmpNum, sum(T.Amount) as TotalAmount
from tblDepartment as D
left join tblEmployee as E
on D.Department = E.Department
left join tblTransaction as T
on E.EmpNumber = T.EmpNumber
group by D.Department, T.EmpNumber
--order by D.Department, T.EmpNumber
go
select * from ViewByDepartment
select * from ViewSummary