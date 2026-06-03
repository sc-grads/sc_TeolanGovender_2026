DECLARE @param varchar(1000) = '127';

DECLARE @sql nvarchar(max) =
    N'
    SELECT *
    FROM [dbo].[tblTransaction] AS T
    WHERE T.EmpNumber = ' + @param;

EXECUTE (@sql);


DECLARE @parameter varchar(1000) = '127' + char(10) + 'SELECT * from dbo.tblTransaction';

DECLARE @sql nvarchar(max) =
    N'
    SELECT *
    FROM [dbo].[tblTransaction] AS T
    WHERE T.EmpNumber = ' + @parameter;

EXECUTE (@sql);

DECLARE @param varchar(1000) = '127';

EXECUTE sys.sp_executesql
    @statement = 
        N'
        SELECT *
        FROM [dbo].[tblTransaction] AS T
    WHERE T.EmpNumber = @EmpNumber;',
    @params = N'@EmpNumber varchar(1000)',
    @EmpNumber = @param;