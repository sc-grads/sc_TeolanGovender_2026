SELECT
CURRENT_TIMESTAMP as RightNow,
getdate() as RightNow2,
SYSDATETIME() as RightNow3,
dateadd(YEAR,1,'2015-01-02 03:04:05') as MyYear,
datepart(hour,'2015-01-02 03:04:05') as Myhour,
datename(WEEKDAY, getdate()) as MyAnswer,
datediff(SECOND,'2015-01-02 03:04:05',getdate()) as SecondsElapsed