select * 
from tblTransaction as T
Where EmpNumber = some -- or "some"
    (Select EmpNumber from tblEmployee where EmpLastName like 'y%')
order by EmpNumber

select * 
from tblTransaction as T
Where EmpNumber <> any -- does not work properly
    (Select EmpNumber from tblEmployee where EmpLastName like 'y%')
order by EmpNumber

select * 
from tblTransaction as T
Where EmpNumber <> all 
    (Select EmpNumber from tblEmployee where EmpLastName like 'y%')
order by EmpNumber

select * 
from tblTransaction as T
Where EmpNumber <= all
    (Select EmpNumber from tblEmployee where EmpLastName like 'y%')
order by EmpNumber

-- anything up to 126 AND
-- anything up to 127 AND
-- anything up to 128 AND
-- anything up to 129

-- ANY = anything up to 129
-- ALL = anything up to 126

-- any/some = OR
-- all = AND

-- 126 <> all(126,127,128,129)
-- 126<>126 AND 126<>127 AND 126<>128 AND 126<>129
-- FALSE    AND TRUE = FALSE

-- 126 <> any(126,127,128,129)
-- 126<>126 OR 126<>127 OR 126<>128 OR 126<>129
-- FALSE    OR TRUE = TRUE
