--This will prompt an error
declare @mydate as datetime = '2015-06-25 01:02:03.456'
select 'the date and time is: ' + @mydate
go

declare @mydate as datetime = '2015-06-25 01:02:03.456'
select convert(nvarchar(20),@mydate) as MyConvertedDate
go

declare @mydate as datetime = '2015-06-25 01:02:03.456'
select cast(@mydate as nvarchar(20)) as MyCastDate

select
--convert(date,'Thursday, 25 June 2015') as MyconvertedDate,  --this will prompt an error
parse('Thursday, 25 June 2015' as date) as MyParsedDate,
parse('Jueves, 25 de junio de 2015' as date using 'es-ES') as MySpanishParsedDate,
format(cast('2015-06-25 01:02:03.456'as datetime),'D') as MyFormattedLongDate,
format(cast('2015-06-25 01:02:03.456'as datetime),'d') as MyFormattedShortDate
