USE [msdb];
GO

SET NOCOUNT ON;

-- 1. Clear out any old versions of this specific job name
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'$(TARGET_JOB_NAME)')
BEGIN
    EXEC msdb.dbo.sp_delete_job @job_name = N'$(TARGET_JOB_NAME)', @delete_unused_schedule = 1;
END;
GO

-- 2. Provision the core automated job agent
DECLARE @jobId BINARY(16);
EXEC msdb.dbo.sp_add_job 
    @job_name = N'$(TARGET_JOB_NAME)', 
    @enabled = 1, 
    @job_id = @jobId OUTPUT;

-- 3. Dynamically discover the physical package filename deployed to the catalog
DECLARE @realPackageName NVARCHAR(100);
SELECT TOP 1 @realPackageName = pk.name
FROM SSISDB.catalog.packages pk
INNER JOIN SSISDB.catalog.projects p ON pk.project_id = p.project_id
INNER JOIN SSISDB.catalog.folders f ON p.folder_id = f.folder_id
WHERE f.name = N'$(CATALOG_FOLDER)' 
  AND p.name = N'$(PROJECT_NAME)';

-- Safe structural fallback if the metadata query hasn't refreshed in memory yet
IF @realPackageName IS NULL
BEGIN
    SET @realPackageName = CASE 
        WHEN N'$(CATALOG_FOLDER)' LIKE '%Production%' THEN N'TimesheetProductionMigrationPK.dtsx'
        ELSE N'TimesheetDevTestMigrationTG.dtsx'
    END;
END;

-- 4. Determine target runtime database environment isolation context
DECLARE @targetDatabase NVARCHAR(100) = CASE 
    WHEN N'$(CATALOG_FOLDER)' LIKE '%Production%' THEN N'TimesheetTGDB'
    ELSE N'TimesheetDB'
END;

-- 5. Construct the perfect native DTExec execution payload string
DECLARE @serverName NVARCHAR(100) = @@SERVERNAME;
DECLARE @ssisCommand NVARCHAR(MAX);

SET @ssisCommand = N'/ISSERVER "\"\SSISDB\$(CATALOG_FOLDER)\$(PROJECT_NAME)\' + @realPackageName + N'\"" /SERVER "\"' + @serverName + N'\"" ' +
                   N'/CALLERINFO SQLAGENT /REPORTING E ' +
                   N'/PARAMETER "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True ' +
                   -- Dynamic Environment Connection Intercept Overrides
                   N'/CONNECTION "\"LocalHost.TimesheetDB\"";"\"Data Source=' + @serverName + N';Initial Catalog=' + @targetDatabase + N';Provider=SQLNCLI11.1;Integrated Security=SSPI;Auto Translate=False;\"" ' +
                   N'/CONNECTION "\"LocalHost.TimesheetCMDB\"";"\"Data Source=' + @serverName + N';Initial Catalog=' + @targetDatabase + N';Provider=SQLNCLI11.1;Integrated Security=SSPI;Auto Translate=False;\""';

-- 6. Bind the step using the native SSIS subsystem execution wrapper
EXEC msdb.dbo.sp_add_jobstep 
    @job_id = @jobId, 
    @step_name = N'Run Integrated Package Process',
    @subsystem = N'SSIS', 
    @command = @ssisCommand,
    @database_name = N'master',
    @retry_attempts = 0;

-- 7. Bind the 30-Second Schedule
EXEC msdb.dbo.sp_add_jobschedule 
    @job_id = @jobId, 
    @name = N'Timesheet_30Sec_Interval',
    @enabled = 1,
    @freq_type = 4,
    @freq_interval = 1,
    @freq_subday_type = 2,
    @freq_subday_interval = 30,
    @active_start_time = 000000;

-- 8. Attach to target server context
EXEC msdb.dbo.sp_add_jobserver 
    @job_id = @jobId, 
    @server_name = @@SERVERNAME;
GO