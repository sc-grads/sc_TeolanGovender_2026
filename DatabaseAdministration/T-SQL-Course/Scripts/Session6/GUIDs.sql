declare @newvalue as uniqueidentifier --GUID
SET @newvalue = NEWID()
SELECT @newvalue as TheNewID
GO
declare @randomnumbergenerator int = DATEPART(MILLISECOND,SYSDATETIME())+1000*(DATEPART(SECOND,SYSDATETIME())
                                     +60*(DATEPART(MINUTE,SYSDATETIME())+60*DATEPART(HOUR,SYSDATETIME())))
SELECT RAND(@randomnumbergenerator) as RandomNumber;

begin tran
Create table tblEmployee4
(UniqueID uniqueidentifier CONSTRAINT df_tblEmployee4_UniqueID DEFAULT NEWID(),
EmpNumber int CONSTRAINT uq_tblEmployee4_EmpNumber UNIQUE)

Insert into tblEmployee4(EmpNumber)
VALUES (1), (2), (3)
select * from tblEmployee4
rollback tran
go
declare @newvalue as uniqueidentifier
SET @newvalue = NEWSEQUENTIALID()
SELECT @newvalue as TheNewID
GO
begin tran
Create table tblEmployee4
(UniqueID uniqueidentifier CONSTRAINT df_tblEmployee4_UniqueID DEFAULT NEWSEQUENTIALID(),
EmpNumber int CONSTRAINT uq_tblEmployee4_EmpNumber UNIQUE)

Insert into tblEmployee4(EmpNumber)
VALUES (1), (2), (3)
select * from tblEmployee4
rollback tran
