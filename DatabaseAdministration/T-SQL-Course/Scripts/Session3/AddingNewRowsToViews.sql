begin tran

insert into ViewByDepartment(EmpNumber,DateOfTransaction,TotalAmount)
values (132,'2015-07-07', 999.99)

select * from ViewByDepartment order by Department, EmpNumber

rollback tran

begin tran
select * from ViewByDepartment order by EmpNumber, DateOfTransaction
--Select * from tblTransaction where EmpNumber in (132,142)

update ViewByDepartment
set EmpNumber = 142
where EmpNumber = 132

select * from ViewByDepartment order by EmpNumber, DateOfTransaction
--Select * from tblTransaction where EmpNumber in (132,142)
rollback tran

USE [70-461]
GO

--if exists(select * from sys.views where name = 'ViewByDepartment')
if exists(select * from INFORMATION_SCHEMA.VIEWS
where [TABLE_NAME] = 'ViewByDepartment' and [TABLE_SCHEMA] = 'dbo')
   drop view dbo.ViewByDepartment
go

CREATE view [dbo].[ViewByDepartment] as 
select D.Department, T.EmpNumber, T.DateOfTransaction, T.Amount as TotalAmount
from tblDepartment as D
left join tblEmployee as E
on D.Department = E.Department
left join tblTransaction as T
on E.EmpNumber = T.EmpNumber
where T.EmpNumber between 120 and 139
WITH CHECK OPTION
--order by D.Department, T.EmpNumber
GO
