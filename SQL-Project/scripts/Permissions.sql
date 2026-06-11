--only works on DB owners server
ALTER ROLE db_owner
ADD MEMBER automation_user;
GO

USE Cloud_Tunnels_TG;
GO

-- Ensure database user exists
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'automation_user')
BEGIN
    CREATE USER automation_user FOR LOGIN automation_user;
END
GO

-- Add to role safely (avoid duplicate error)
IF NOT EXISTS (
    SELECT * FROM sys.database_role_members drm
    JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
    JOIN sys.database_principals m ON drm.member_principal_id = m.principal_id
    WHERE r.name = 'db_owner' AND m.name = 'automation_user'
)
BEGIN
    ALTER ROLE db_owner ADD MEMBER automation_user;
END
GO

-----------------------------------------------------

ALTER DATABASE Cloud_Tunnels_TG
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE Cloud_Tunnels_TG;
GO

USE master;
GO
ALTER DATABASE [CloudTunneling_CM]
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE [CloudTunneling_CM];
GO

ALTER DATABASE [CloudTunneling_CM] SET MULTI_USER WITH ROLLBACK IMMEDIATE;


SELECT name, state_desc
FROM sys.databases
WHERE name = 'Cloud_Tunnels_TG';

------------------------------------------------------------------------
USE Cloud_Tunnels_TG
SELECT * FROM [dbo].[DeploymentLogs]
SELECT * FROM [dbo].[Users]


---------------------------------------------
USE CloudTunneling_CM
SELECT * FROM [dbo].[DeploymentLog]
SELECT * FROM [dbo].[Team]