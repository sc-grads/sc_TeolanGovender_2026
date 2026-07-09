USE [msdb];
GO
SET NOCOUNT ON;

-- 1. Clear Out Stale Existing Job Definitions
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'$(TARGET_JOB_NAME)')
BEGIN
    EXEC msdb.dbo.sp_delete_job @job_name = N'$(TARGET_JOB_NAME)', @delete_unused_schedule = 1;
END;
GO

-- 2. Provision the Core Automated Job Agent
DECLARE @jobId BINARY(16);
EXEC msdb.dbo.sp_add_job     
    @job_name = N'$(TARGET_JOB_NAME)', 
    @enabled = 1, 
    @job_id = @jobId OUTPUT;

-- 3. Prepare the T-SQL Execution Payload
-- Explicitly CONVERT the sql_variant to NVARCHAR to pass the engine type check safely
DECLARE @tsqlCommand NVARCHAR(MAX) = N'
    DECLARE @execution_id BIGINT;
    DECLARE @resolved_path NVARCHAR(255);

    -- Added CONVERT to enforce the correct string type string mapping
    SELECT TOP 1 @resolved_path = CONVERT(NVARCHAR(255), op.design_default_value)
    FROM [SSISDB].[catalog].[object_parameters] op
    INNER JOIN [SSISDB].[catalog].[projects] p ON op.project_id = p.project_id
    INNER JOIN [SSISDB].[catalog].[folders] f ON p.folder_id = f.folder_id
    WHERE f.name = N''$(CATALOG_FOLDER)''
      AND p.name = N''$(PROJECT_NAME)''
      AND op.parameter_name = N''Source_File_Directory'';
    
    -- Create the execution instance in the SSIS catalog
    EXEC [SSISDB].[catalog].[create_execution] 
        @folder_name = N''$(CATALOG_FOLDER)'', 
        @project_name = N''$(PROJECT_NAME)'', 
        @package_name = N''Package2.dtsx'', 
        @reference_id = NULL, 
        @use32bitruntime = FALSE, 
        @execution_id = @execution_id OUTPUT;
    
    -- Dynamically apply the fetched path parameter to the execution run
    BEGIN TRY
        EXEC [SSISDB].[catalog].[set_execution_parameter_value] 
            @execution_id, @object_type = 20, @parameter_name = N''Source_File_Directory'', @parameter_value = @resolved_path;
    END TRY
    BEGIN CATCH
        EXEC [SSISDB].[catalog].[set_execution_parameter_value] 
            @execution_id, @object_type = 30, @parameter_name = N''Project::Source_File_Directory'', @parameter_value = @resolved_path;
    END CATCH;
    
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

-- 5. Attach to Target Server Context
EXEC msdb.dbo.sp_add_jobserver     
    @job_id = @jobId, 
    @server_name = @@SERVERNAME;
GO