declare @mydate as datetime = '2015-06-24 12:34:56.124'
Declare @mydate2 as datetime = '20150624 12:34:56.124'

Select
@mydate as MyDate,
@mydate2 as MyDate2,
datefromparts(2015,06,24) as ThisDate,
DATETIME2FROMPARTS(2015,06,24,12,34,56,124,3) as ThatDate,
year(@mydate) as myYear, month(@mydate) as myMonth, day(@mydate) as myDay