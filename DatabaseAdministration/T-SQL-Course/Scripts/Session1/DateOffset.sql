declare @myDateOffset as datetimeoffset = '2015-06-25 01:02:03.456 +05:30'   -- 8 to 10 bytes
select @myDateOffset as MyDateOffset


declare @myDate as datetime2 = '2015-06-25 01:02:03.456'
SELECT
TODATETIMEOFFSET(@myDate,'+05:30') as MyDateOffset2,
DATETIMEOFFSETFROMPARTS(2015,06,25,1,2,3,456,5,30,3) as MyDateOffset3,
SYSDATETIMEOFFSET() as TimeNowWithOffset,
SYSUTCDATETIME() as TimeNowUTC

declare @mydateOffset as datetimeoffset = '2015-06-25 01:02:03.456 +05:30'
select SWITCHOFFSET(@myDateOffset, '-05:00') as MyDateOffsetTexas