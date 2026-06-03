select T.*
from tblTransaction as T
right join tblEmployee as E
on T.EmpNumber = E.EmpNumber
where E.EmpNumber between 120 and 299 
and T.EmpNumber is not null