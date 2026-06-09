USE [Cloud-Tunnel-TG];
CREATE USER automation_user FOR LOGIN automation_user;
ALTER ROLE db_owner ADD MEMBER automation_user;