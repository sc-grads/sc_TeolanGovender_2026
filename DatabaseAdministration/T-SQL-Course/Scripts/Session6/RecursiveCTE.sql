begin tran
alter table tblEmployee
add Manager int
go
update tblEmployee
set Manager = ((EmpNumber-123)/10)+123
where EmpNumber>123;
with myTable as
(select EmpNumber, EmpFirstName, EmpLastName, 0 as BossLevel --Anchor
from tblEmployee
where Manager is null
UNION ALL --UNION ALL!!
select E.EmpNumber, E.EmpFirstName, E.EmpLastName, myTable.BossLevel + 1 --Recursive
from tblEmployee as E
join myTable on E.Manager = myTable.EmpNumber
) --recursive CTE

select * from myTable

rollback tran