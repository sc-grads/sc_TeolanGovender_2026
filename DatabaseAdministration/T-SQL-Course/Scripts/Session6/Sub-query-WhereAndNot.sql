select * 
from tblTransaction as T
Where EmpNumber in
    (Select EmpNumber from tblEmployee where EmpLastName not like 'y%')
order by EmpNumber -- must be in tblEmployee AND tblTransaction, and not 126-129
                        -- INNER JOIN

select * 
from tblTransaction as T
Where EmpNumber not in
    (Select EmpNumber from tblEmployee where EmpLastName like 'y%')
order by EmpNumber -- must be in tblTransaction, and not 126-129
                        -- LEFT JOIN
