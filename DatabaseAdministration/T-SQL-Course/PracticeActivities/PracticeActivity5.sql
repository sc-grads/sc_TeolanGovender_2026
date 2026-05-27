select [name]
from sys.all_columns

SELECT [name] + 'A'
FROM sys.all_columns;

SELECT [name] + N'Ⱥ'
FROM sys.all_columns;

SELECT SUBSTRING([name], 2, LEN([name]))
FROM sys.all_columns;