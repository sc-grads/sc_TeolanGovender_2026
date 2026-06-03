select T.* 
from tblTransaction as T
inner join tblEmployee as E
on E.EmpNumber = T.EmpNumber
where E.EmpLastName like 'y%'
order by T.EmpNumber

select * 
from tblTransaction as T
Where EmpNumber in
    (126, 127, 128,129)
order by EmpNumber

select * 
from tblTransaction as T
Where EmpNumber in
    (Select EmpNumber from tblEmployee where EmpLastName like 'y%')
order by EmpNumber