CREATE DATABASE JoinPractice;
USE JoinPractice;




--EMPLOYEES TABLE
CREATE TABLE Employees
(
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(50)
);
SELECT * FROM Employees


--SALES TABLE
CREATE TABLE Sales
(
    SaleID INT PRIMARY KEY,
    EmpID INT,
    Amount DECIMAL(10,2)
);

SELECT * FROM Sales

--INSERT DATA INTO EMPLOYEES
INSERT INTO Employees (EmpID, EmpName)
VALUES
(1, 'Sarah'),
(2, 'Mike'),
(3, 'John');


--INSERT DATA INTO SALES
INSERT INTO Sales (SaleID, EmpID, Amount)
VALUES
(101, 1, 500.00),
(102, 1, 300.00),
(103, 2, 700.00),
(104, 5, 900.00); -- Notice EmpID 5 does not exist


SELECT * FROM Employees;
SELECT * FROM Sales;

-- INNER JOIN
-- Only matching rows
SELECT
    e.EmpName,
    s.Amount
FROM Employees e
INNER JOIN Sales s
ON e.EmpID = s.EmpID;


-- LEFT JOIN
-- Keep ALL employees
SELECT
    e.EmpName,
    s.Amount
FROM Employees e
LEFT JOIN Sales s
ON e.EmpID = s.EmpID;


-- RIGHT JOIN
-- Keep ALL sales
SELECT
    e.EmpName,
    s.Amount
FROM Employees e
RIGHT JOIN Sales s
ON e.EmpID = s.EmpID;


-- FULL OUTER JOIN
-- Keep everything from both tables
SELECT
    e.EmpName,
    s.Amount
FROM Employees e
FULL OUTER JOIN Sales s
ON e.EmpID = s.EmpID;


-- FIND EMPLOYEES WITH NO SALES
SELECT
    e.EmpName
FROM Employees e
LEFT JOIN Sales s
ON e.EmpID = s.EmpID
WHERE s.EmpID IS NULL;



-- FIND SALES WITH NO EMPLOYEE
SELECT
    s.SaleID,
    s.Amount
FROM Employees e
RIGHT JOIN Sales s
ON e.EmpID = s.EmpID
WHERE e.EmpID IS NULL;