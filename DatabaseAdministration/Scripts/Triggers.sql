SELECT TOP (1000) [EmpID]
      ,[EmpName]
      ,[EmpTitle]
  FROM [AdventureWorks2019].[dbo].[Employee]


  CREATE TRIGGER EmployeeInsert
   ON  Employee
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
Insert into EmployeetriggerHistory values ((select top(1) EmpID from employee),'Insert')

END
GO

insert into [Employee] ([EmpID],[EmpName],[EmpTitle]) values (1,'Qasim','Area Manager')

Select * from EmployeetriggerHistory