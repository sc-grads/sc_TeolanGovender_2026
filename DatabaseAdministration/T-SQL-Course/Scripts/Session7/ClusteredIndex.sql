create clustered index idx_tblEmployee on [dbo].[tblEmployee]([EmpNumber])

drop index idx_tblEmployee on [dbo].[tblEmployee]

select * from [dbo].[tblEmployee2] where [EmpNumber] = 127  --seek = few number of rows based on the index
select * from [dbo].[tblEmployee2]  --scan = going through the entire table

select *
into [dbo].[tblEmployee2]
from [dbo].[tblEmployee]
where EmpNumber <> 131




alter table [dbo].[tblEmployee2]
add constraint pk_tblEmployee2 PRIMARY KEY(EmpNumber)

create table myTable (Field1 int primary key)

---------------------------------------------------------

select * from [dbo].[tblEmployee] where [EmpNumber] = 127  --seek = few number of rows based on the index
select * from [dbo].[tblEmployee]  --scan = going through the entire table
