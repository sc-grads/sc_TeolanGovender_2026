--Implicit
DECLARE @myvar as Decimal(5,2) = 3
SELECT @myvar

--Explicit
SELECT CONVERT(decimal(5,2),3)/2
SELECT CAST(3 as decimal(5,2))/2