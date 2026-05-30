alter table tblEmployee
ADD CONSTRAINT unqGovernmentID unique (EmpGovernmentID);

Select EmpGovernmentID, count(EmpGovernmentID) as Mycount from tblEmployee
group by EmpGovernmentID
having count(EmpGovernmentID)>1

Select * from tblEmployee where EmpGovernmentID IN ('HN513777D','TX593671R')

begin tran
delete from tblEmployee
where EmpNumber < 3

Delete top(2) from tblEmployee
where EmpNumber in (131, 132)

Select * from tblEmployee where EmpGovernmentID IN ('HN513777D','TX593671R')

commit tran

rollback tran