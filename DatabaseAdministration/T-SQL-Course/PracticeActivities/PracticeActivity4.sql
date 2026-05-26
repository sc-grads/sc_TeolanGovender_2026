select system_type_id, column_id, system_type_id / column_id as Calculation
from sys.all_columns


-- Correct the calculation by converting to decimal
SELECT 
    system_type_id,
    column_id,
    CAST(system_type_id AS DECIMAL(10,2)) / column_id AS Calculation
FROM sys.all_columns;


-- Round fractions down
SELECT 
    system_type_id,
    column_id,
    FLOOR(CAST(system_type_id AS DECIMAL(10,2)) / column_id) AS Calculation
FROM sys.all_columns;


-- Round fractions up
SELECT 
    system_type_id,
    column_id,
    CEILING(CAST(system_type_id AS DECIMAL(10,2)) / column_id) AS Calculation
FROM sys.all_columns;


-- Round to 1 decimal place
SELECT 
    system_type_id,
    column_id,
    ROUND(CAST(system_type_id AS DECIMAL(10,2)) / column_id, 1) AS Calculation
FROM sys.all_columns;


-- Multiply by 2 and convert to tinyint safely
SELECT 
    system_type_id,
    TRY_CAST(system_type_id * 2 AS TINYINT) AS TinyIntValue
FROM sys.all_columns;