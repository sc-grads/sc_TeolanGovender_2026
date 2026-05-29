ALTER Table tblEmployee
--drop column [Department]
ADD Department VARCHAR(50);

SELECT * FROM [dbo].[tblEmployee]

INSERT INTO [dbo].[tblEmployee]
VALUES(123,'Jane','','Zwilling','AB123456G','1985/01/01','Commercial')

DELETE FROM [dbo].[tblEmployee]
WHERE Department is NULL;