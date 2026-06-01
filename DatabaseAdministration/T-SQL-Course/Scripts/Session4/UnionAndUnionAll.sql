-- Combine rows from both pseudo tables, removing duplicates
select * from inserted
union 
select * from deleted


-- UNION removes duplicate greetings
select convert(char(5),'hi') as Greeting
union all
select convert(char(11),'hello there') as GreetingNow
union all
select convert(char(11),'bonjour')
union all
select convert(char(11),'hi')


-- SQL converts smaller integer type to larger compatible type
select convert(tinyint, 45) as Mycolumn
union
select convert(bigint, 456)


-- Error example: incompatible data types (int vs string)
select 4
union
select 'hi there'