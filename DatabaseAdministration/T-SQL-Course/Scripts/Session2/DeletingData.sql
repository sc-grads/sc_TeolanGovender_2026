SELECT *
FROM
(SELECT E.empNumber as ENumber, E.EmpFirstName, E.EmpLastName, T.EmpNumber as TNumber, sum(T.Amount) as TotalAmount

From tblEmployee as E
right join tblTransaction as T
on E.EmpNumber = T.EmpNumber
group by E.EmpNumber, T.EmpNumber, E.EmpFirstName,E.EmpLastName, T.Amount) as newTable
Where ENumber is null
order by ENumber, TNumber, EmpFirstName, EmpLastName

begin transaction

delete tblTransaction
From tblEmployee as E
right join tblTransaction as T
on E.EmpNumber = T.EmpNumber
Where e.EmpNumber is null

SELECT count(*) from tblTransaction --tells us how many rows

rollback transaction
