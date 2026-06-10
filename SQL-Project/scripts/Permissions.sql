--Permissions.sql
--only works on DB owners server
ALTER ROLE db_owner
ADD MEMBER automation_user;
GO