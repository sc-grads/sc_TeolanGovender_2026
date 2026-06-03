create nonclustered index idx_tblEmployee_DateofBirth on [dbo].[tblEmployee]([DateofBirth])
create nonclustered index idx_tblEmployee_DateofBirth_Department on [dbo].[tblEmployee]([DateofBirth],Department)

drop index idx_tblEmployee on [dbo].[tblEmployee]

select * from [dbo].[tblEmployee2] where [EmpNumber] = 127
select * from [dbo].[tblEmployee2]

select DateofBirth, Department
from [dbo].[tblEmployee]
where DateofBirth>='1992-01-01' and DateofBirth<'1993-01-01'

--seek = few number of rows based on the index
--scan = going through the entire table

alter table [dbo].[tblDepartment]
add constraint unq_tblDepartment UNIQUE(Department)