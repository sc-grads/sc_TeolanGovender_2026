;WITH tblWithRanking AS
(
    SELECT 
        D.Department, 
        EmpNumber, 
        EmpFirstName, 
        EmpLastName,
        RANK() OVER (PARTITION BY D.Department ORDER BY E.EmpNumber) AS TheRank
    FROM tblDepartment AS D 
    JOIN tblEmployee AS E 
        ON D.Department = E.Department
),
Transaction2014 AS
(
    SELECT *
    FROM tblTransaction 
    WHERE DateOfTransaction < '2015-01-01'
)

SELECT *
FROM tblWithRanking 
LEFT JOIN Transaction2014 
    ON tblWithRanking.EmpNumber = Transaction2014.EmpNumber
WHERE TheRank <= 5
ORDER BY Department, tblWithRanking.EmpNumber;