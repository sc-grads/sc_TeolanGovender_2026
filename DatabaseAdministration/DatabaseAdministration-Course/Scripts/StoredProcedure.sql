CREATE PROCEDURE [dbo].[SelectAllPersonAddressWithParamswithEncryption] (@City NVARCHAR(30) = 'New York')
WITH ENCRYPTION
AS

--BEGIN
SET NOCOUNT ON

SELECT * FROM  Person.Address where City = @city

--END
exec [SelectAllPersonAddressWithParamswithEncryption]

drop procedure [dbo].[SelectAllPersonAddressWithParamswithEncryption]