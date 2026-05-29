SELECT Department FROM
(SELECT Department, count(*) AS NumberOfDepartments
FROM tblEmployee
GROUP BY Department) AS newTable


SELECT Distinct Department,
convert(varchar(20),N'') as DepartmentHead
into tblDepartment
FROM tblEmployee

select * from tblDepartment
