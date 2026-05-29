Select left(EmpLastName,1) as Initial, count(*) as CountOfInitial
from tblEmployee
group by left(EmpLastName,1)
order by count(*) --left(EmployeeLastName,1)

Select top(5) left(EmpLastName,1) as Initial, count(*) as CountOfInitial
from tblEmployee
group by left(EmpLastName,1)
order by count(*) DESC--left(EmployeeLastName,1)

Select left(EmpLastName,1) as Initial, count(*) as CountOfInitial
from tblEmployee
group by left(EmpLastName,1)
having count(*)>=50
order by count(*) DESC

Select left(EmpLastName,1) as Initial, count(*) as CountOfInitial
from tblEmployee
group by left(EmpLastName,1)
having count(*)>=1
order by Initial ASC

--order of clauses
--select
--from
--WHERE
--group by
--having
--order