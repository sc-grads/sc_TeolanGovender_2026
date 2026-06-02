-- Create a simple test table
CREATE TABLE NewTempTable (
    Emp VARCHAR(10),
    Date DATE,
    Sales INT
);

-- Insert sample data (two rows have same date on purpose)
INSERT INTO NewTempTable (Emp, Date, Sales)
VALUES 
('A', '2024-01-01', 10),
('A', '2024-01-01', 20),
('A', '2024-02-01', 30);

-- View raw data
SELECT * 
FROM NewTempTable;

-------------------------------------------------------
-- ROWS: calculates row by row (each record treated separately)
SELECT
    Emp,
    Date,
    Sales,

    SUM(Sales) OVER (
        PARTITION BY Emp
        ORDER BY Date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RowsRunningTotal

FROM NewTempTable;

-------------------------------------------------------
-- RANGE: groups rows with same date together
SELECT
    Emp,
    Date,
    Sales,

    SUM(Sales) OVER (
        PARTITION BY Emp
        ORDER BY Date
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RangeRunningTotal

FROM NewTempTable;



SELECT
    Emp,
    Date,
    Sales,

    SUM(Sales) OVER (
        PARTITION BY Emp
        ORDER BY Date
    ) AS DefaultRunningTotal

FROM NewTempTable;

DROP Table NewTempTable