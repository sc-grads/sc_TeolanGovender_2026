SELECT * FROM [dbo].[tblEmployee]
WHERE not EmpNumber>200

SELECT * FROM [dbo].[tblEmployee]
WHERE EmpNumber != 200

SELECT * FROM [dbo].[tblEmployee]
WHERE EmpNumber >= 200 and EmpNumber<=209

SELECT * FROM [dbo].[tblEmployee]
WHERE EmpNumber < 200 or EmpNumber>209

SELECT * FROM [dbo].[tblEmployee]
WHERE EmpNumber between 200 and 209

SELECT * FROM [dbo].[tblEmployee]
WHERE EmpNumber not between 200 and 209

SELECT * FROM [dbo].[tblEmployee]
WHERE EmpNumber in (200, 204, 208)