IF NOT EXISTS (SELECT 1 FROM Users WHERE first_name = 'Teolan' AND last_name = 'Govender')
BEGIN
    INSERT INTO Users (first_name, last_name)
    VALUES ('Teolan', 'Govender');
END

IF NOT EXISTS (SELECT 1 FROM Users WHERE first_name = 'Charmane' AND last_name = 'Mchunu')
BEGIN
    INSERT INTO Users (first_name, last_name)
    VALUES ('Charmane', 'Mchunu');
END