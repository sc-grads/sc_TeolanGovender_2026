Select *, (select count(EmpNumber)
           from tblTransaction as T
		   where T.EmpNumber = E.EmpNumber) as NumTransactions,
		  (Select sum(Amount)
		   from tblTransaction as T
		   where T.EmpNumber = E.EmpNumber) as TotalAmount
from tblEmployee as E
Where E.EmpLastName like 'y%' --correlated subquery
