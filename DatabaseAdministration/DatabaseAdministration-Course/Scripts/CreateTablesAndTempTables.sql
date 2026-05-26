CREATE TABLE [AdventureWorks2019].[sales].[visits] (
visit_id INT PRIMARY KEY IDENTITY (1, 1),
first_name VARCHAR (50) NOT NULL,
last_naame VARCHAR (50) NOT NULL,
visited_at DATETIME,
phone VARCHAR(20),
store_id INT NOT NULL,
FOREIGN KEY (store_id) REFERENCES sales.storenew(store_id)
)

CREATE TABLE [AdventureWorks2019].[sales].[storenew] (
store_id INT NOT NULL,
sales INT
)

SELECT * FROM [AdventureWorks2019].[sales].[storenew]
SELECT * FROM [AdventureWorks2019].[sales].[visits]

select BusinessEntityID, firstname,lastname, Title
into #TempPersonTable
from [Person].[Person]
where title = 'mr.'


SELECT * FROM #TempPersonTable

SELECT * FROM [AdventureWorks2019].[dbo].[EmployeePhoneDetail]