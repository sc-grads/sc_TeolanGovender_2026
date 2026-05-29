select * from tblEmployee Where EmpNumber = 194
select * from tblTransaction Where EmpNumber = 3
select * from tblTransaction Where EmpNumber = 194

begin tran
select * from tblEmployee Where EmpNumber = 194

update tblTransaction
set EmpNumber = 194
from tblTransaction
where EmpNumber = 3

rollback tran