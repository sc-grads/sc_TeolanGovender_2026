-- Turn on timing statistics (how long queries take)
--SET STATISTICS TIME ON

-- Create a scalar function that returns total transaction amount per employee
CREATE FUNCTION fnc_TransactionTotal (@intEmployee AS INT)
RETURNS MONEY
AS
BEGIN
    -- Variable to store total amount
    DECLARE @TotalAmount AS MONEY

    -- Calculate total transaction amount for a specific employee
    SELECT @TotalAmount = SUM(Amount)
    FROM dbo.tblTransaction
    WHERE EmpNumber = @intEmployee

    -- Return the calculated total
    RETURN @TotalAmount
END
GO

-- Show execution plan (text format)
SET SHOWPLAN_ALL ON
GO
SET SHOWPLAN_TEXT ON
GO

-- OPTION 1: Using scalar function (runs per employee row)
SELECT EmpNumber, dbo.fnc_TransactionTotal(EmpNumber)
FROM dbo.tblEmployee

-- OPTION 2: Using JOIN + GROUP BY (set-based, more efficient)
SELECT E.EmpNumber, SUM(Amount) AS TotalAmount
FROM dbo.tblEmployee AS E
LEFT JOIN dbo.tblTransaction AS T
    ON E.EmpNumber = T.EmpNumber
GROUP BY E.EmpNumber

-- Turn off performance/statistics tools
SET STATISTICS TIME OFF
SET SHOWPLAN_ALL OFF

-- OPTION 3: Scalar function again (same row-by-row issue)
SELECT EmpNumber, dbo.fnc_TransactionTotal(EmpNumber)
FROM dbo.tblEmployee

-- OPTION 4: JOIN + GROUP BY again (preferred method)
SELECT E.EmpNumber, SUM(T.Amount) AS TotalAmount
FROM dbo.tblEmployee AS E
LEFT JOIN dbo.tblTransaction AS T
    ON E.EmpNumber = T.EmpNumber
GROUP BY E.EmpNumber

-- OPTION 5: Correlated subquery (runs SUM per employee row)
SELECT E.EmpNumber,
(
    SELECT SUM(Amount)
    FROM tblTransaction AS T
    WHERE T.EmpNumber = E.EmpNumber
) AS TotalAmount
FROM dbo.tblEmployee AS E