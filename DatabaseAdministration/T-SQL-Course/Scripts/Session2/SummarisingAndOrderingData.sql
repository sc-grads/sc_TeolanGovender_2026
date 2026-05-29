select * from tblEmployee
Where DateOfBirth between '19760101' and '19861231'

select * from tblEmployee
where DateOfBirth >= '19760101' and DateOfBirth < '19861231'

select * from tblEmployee
Where year(DateOfBirth) between 1976 and 1986  --Do Not Use

SELECT year(DateOfBirth) as YearOfDateOfBirth, count(*) as NumberBorn
FROM tblEmployee
GROUP BY year(DateOfBirth)

select * from tblEmployee
where year(DateOfBirth) = 1967

SELECT year(DateOfBirth) as  BirthYear, count(*) as NumberBorn
FROM tblEmployee
WHERE 1=1
GROUP BY year(DateOfBirth)


SELECT YEAR(DateOfBirth) as BirthYear, count(*) as NumberBorn
FROM tblEmployee
WHERE 1=1
GROUP BY year(DateOfBirth)
ORDER BY Year(DateOfBirth)