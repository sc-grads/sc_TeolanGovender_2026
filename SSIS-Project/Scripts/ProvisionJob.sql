USE [msdb];
GO

SET NOCOUNT ON;

-- 1. Clear out any old versions of this specific job name
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'$(TARGET_JOB_NAME)')
BEGIN
    EXEC msdb.dbo.sp_delete_job @job_name = N'$(TARGET_JOB_NAME)', @delete_unused_schedule = 1;
END;
GO

-- 2. Provision the clean automated job
DECLARE @jobId BINARY(16);
EXEC msdb.dbo.sp_add_job 
    @job_name = N'$(TARGET_JOB_NAME)', 
    @enabled = 1, 
    @job_id = @jobId OUTPUT;

-- 3. Prepare the T-SQL Execution payload 
DECLARE @tsqlCommand NVARCHAR(MAX) = N'
    DECLARE @execution_id BIGINT;
    DECLARE @real_package_name NVARCHAR(100);

    -- Automatically discover the package name from your explicit folder name structure
    SELECT TOP 1 @real_package_name = pk.name
    FROM [SSISDB].[catalog].[packages] pk
    INNER JOIN [SSISDB].[catalog].[projects] p ON pk.project_id = p.project_id
    INNER JOIN [SSISDB].[catalog].[folders] f ON p.folder_id = f.folder_id
    WHERE f.name = N''$(CATALOG_FOLDER)''
      AND p.name = N''$(PROJECT_NAME)'';

    -- Create the execution instance
    EXEC [SSISDB].[catalog].[create_execution] 
        @folder_name = N''$(CATALOG_FOLDER)'', 
        @project_name = N''$(PROJECT_NAME)'', 
        @package_name = @real_package_name, 
        @reference_id = NULL, 
        @use32bitruntime = FALSE, 
        @execution_id = @execution_id OUTPUT;

    -- Execute the package natively using your hardcoded C:\Timesheets folder rules
    EXEC [SSISDB].[catalog].[start_execution] @execution_id;
';

EXEC msdb.dbo.sp_add_jobstep 
    @job_id = @jobId, 
    @step_name = N'Run Integrated Package Process',
    @subsystem = N'TSQL',
    @database_name = N'master',
    @command = @tsqlCommand,
    @retry_attempts = 0;

-- 4. Bind the 30-Second Schedule
EXEC msdb.dbo.sp_add_jobschedule 
    @job_id = @jobId, 
    @name = N'Timesheet_30Sec_Interval',
    @enabled = 1,
    @freq_type = 4,
    @freq_interval = 1,
    @freq_subday_type = 2,
    @freq_subday_interval = 30,
    @active_start_time = 000000;

-- 5. Attach to current instance context
EXEC msdb.dbo.sp_add_jobserver 
    @job_id = @jobId, 
    @server_name = @@SERVERNAME;
GO