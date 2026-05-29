SELECT E.empNumber as ENumber, E.EmpFirstName, E.EmpLastName, T.EmpNumber as TNumber, sum(T.Amount) as TotalAmount

From tblEmployee as E
Left join tblTransaction as T
on E.EmpNumber = T.EmpNumber
group by E.EmpNumber, T.EmpNumber, E.EmpFirstName,E.EmpLastName
order by E.EmpNumber,T.EmpNumber,E.EmpFirstName,E.EmpLastName


SELECT *
FROM
(SELECT E.empNumber as ENumber, E.EmpFirstName, E.EmpLastName, T.EmpNumber as TNumber, sum(T.Amount) as TotalAmount

From tblEmployee as E
left join tblTransaction as T
on E.EmpNumber = T.EmpNumber
group by E.EmpNumber, T.EmpNumber, E.EmpFirstName,E.EmpLastName) as newTable
Where TNumber is null
order by ENumber, TNumber, EmpFirstName, EmpLastName