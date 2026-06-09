--Permissions.sql
USE Cloud_Tunnels_TG;
GO

IF NOT EXISTS (
    SELECT * FROM sys.database_principals
    WHERE name = 'automation_user'
)
BEGIN
    CREATE USER automation_user
    FOR LOGIN automation_user;
END
GO

ALTER ROLE db_owner
ADD MEMBER automation_user;
GO