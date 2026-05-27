DECLARE @myvar AS numeric(7,2) = 3
SELECT POWER(@myvar,2)
SELECT SQUARE(@myvar)
SELECT POWER(@myvar,0.5)
SELECT SQRT(@myvar)

DECLARE @myvar AS numeric(7,2) = 12.345

--always rounds down
SELECT FLOOR(@myvar) as myFloor

--always rounds up
SELECT CEILING(@myvar) as myCeiling

--rounds to the nearest value
SELECT ROUND(@myvar,0) as myRound

SELECT PI() as myPI
SELECT EXP(1) as e

DECLARE @myvar AS numeric(7,2) = -456.3542

--Absolute(ABS) makes it positive and SIGN shows you the sign
SELECT ABS(@myvar) AS myABS, SIGN(@myvar) as mySign

--generates a random decimal number between 0 and 1
SELECT RAND(-34546786)