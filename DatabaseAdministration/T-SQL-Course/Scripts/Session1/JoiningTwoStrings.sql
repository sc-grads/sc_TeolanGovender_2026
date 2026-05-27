declare @firstname as nvarchar(20)
declare @middlename as nvarchar(20)
declare @lastname as nvarchar(20)

set @firstname = 'Sarah'
set @lastname = 'Milligan'

Select @firstname + ' ' + @middlename + ' ' + @lastname AS FullName1,
@firstname + iif(@middlename is null, '', + ' '+@middlename)+ ' ' + @lastname AS FullName2