select * 
from tblTransaction as T
left join (select * from tblEmployee
where EmpLastName like 'y%') as E
on E.EmpNumber = T.EmpNumber
order by T.EmpNumber

select * 
from tblTransaction as T
left join tblEmployee as E
on E.EmpNumber = T.EmpNumber
Where E.EmpLastName like 'y%'
order by T.EmpNumber

select * 
from tblTransaction as T
left join tblEmployee as E
on E.EmpNumber = T.EmpNumber
and E.EmpLastName like 'y%'
order by T.EmpNumber