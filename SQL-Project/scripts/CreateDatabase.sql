--CreateDatabase.sql
IF DB_ID('Cloud_Tunnels_TG') IS NULL
BEGIN
    CREATE DATABASE Cloud_Tunnels_TG;
END
GO

USE [Cloud_Tunnels_TG];
CREATE USER automation_user FOR LOGIN automation_user;
ALTER ROLE db_owner ADD MEMBER automation_user;