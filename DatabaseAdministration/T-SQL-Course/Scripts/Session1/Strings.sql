DECLARE @chrMyCharacters as char(10)
set @chrMyCharacters = 'hello'
SELECT @chrMyCharacters as myString, len(@chrMyCharacters) as MyLength, DATALENGTH(@chrMyCharacters) as myDataLenght
