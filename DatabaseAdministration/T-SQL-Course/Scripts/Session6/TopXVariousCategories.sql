select * from
(select D.Department, EmpNumber, EmpFirstName, EmpLastName,
       rank() over(partition by D.Department order by E.EmpNumber) as TheRank
 from tblDepartment as D 
 join tblEmployee as E on D.Department = E.Department) as MyTable
where TheRank <= 5
order by Department, EmpNumber
