SELECT 
    DATENAME(MONTH, DateofBirth) AS MonthName,
    COUNT(*) AS NumberEmployees,
    COUNT(EmpMiddleName) AS NumberOfMiddleNames,
    COUNT(*) - COUNT(EmpMiddleName) AS NoMiddleName,
    MIN(DateofBirth) AS EarliestDateOfBirth
FROM tblEmployee
GROUP BY 
    DATENAME(MONTH, DateofBirth),
    DATEPART(MONTH, DateofBirth)
ORDER BY DATEPART(MONTH, DateofBirth);
