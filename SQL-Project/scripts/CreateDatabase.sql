--CreateDatabase.sql
IF DB_ID('Cloud_Tunnels_TG') IS NULL
BEGIN
    CREATE DATABASE Cloud_Tunnels_TG;
END
GO