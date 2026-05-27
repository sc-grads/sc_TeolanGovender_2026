select 'My Number is: ' + convert(varchar(20),4567)
select 'My Number is: ' + cast(4567 as varchar(20))

select 'My salary is: $' + convert(varchar(20),2345.6)
select 'My salary is:' + format(2345.6,'C')