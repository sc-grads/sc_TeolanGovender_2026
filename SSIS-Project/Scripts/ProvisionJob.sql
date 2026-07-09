USE [msdb];
GO
SET NOCOUNT ON;

-- 1. Clear Out Stale Existing Job Definitions to Avoid Metadata Collisions
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'Run_Timesheet_Package')
BEGIN
    EXEC msdb.dbo.sp_delete_job @job_name = N'Run_Timesheet_Package', @delete_unused_schedule = 1;
END;
GO

-- 2. Provision the Core Automated Job Agent (No Email Alerts)
DECLARE @jobId BINARY(16);
EXEC msdb.dbo.sp_add_job     
    @job_name = N'Run_Timesheet_Package', 
    @enabled = 1, 
    @job_id = @jobId OUTPUT;

-- 3. Add Execution Step Target running as T-SQL to utilize the Database Engine File Access
-- This executes the catalog package directly and applies the correct parameter path mapping
DECLARE @tsqlCommand NVARCHAR(MAX) = N'
    DECLARE @execution_id BIGINT;
    
    -- Create the execution instance in the SSIS catalog
    EXEC [SSISDB].[catalog].[create_execution] 
        @folder_name = N''PracticeActivities'', 
        @project_name = N''TimesheetIntegrationTestTwo'', 
        @package_name = N''Package2.dtsx'', 
        @reference_id = NULL, 
        @use32bitruntime = FALSE, 
        @execution_id = @execution_id OUTPUT;
    
    -- Try setting it via Project Scope (Object Type 20)
    BEGIN TRY
        EXEC [SSISDB].[catalog].[set_execution_parameter_value] 
            @execution_id, 
            @object_type = 20, 
            @parameter_name = N''Source_File_Directory'', 
            @parameter_value = N''c:\sc_CharmaneMchunu_2026\SSIS-Project-TG\Timesheets\'';
    END TRY
    BEGIN CATCH
        -- Fallback to strict Project Literal Scope (Object Type 30) if required
        EXEC [SSISDB].[catalog].[set_execution_parameter_value] 
            @execution_id, 
            @object_type = 30, 
            @parameter_name = N''Project::Source_File_Directory'', 
            @parameter_value = N''c:\sc_CharmaneMchunu_2026\SSIS-Project-TG\Timesheets\'';
    END CATCH;
    
    -- Fire off the package synchronously under the engine
    EXEC [SSISDB].[catalog].[start_execution] @execution_id;
';

EXEC msdb.dbo.sp_add_jobstep     
    @job_id = @jobId, 
    @step_name = N'Run Integrated Package Process',
    @subsystem = N'TSQL',              -- ◄ Changed from 'SSIS' to run under Engine file rights
    @database_name = N'master',
    @command = @tsqlCommand,
    @retry_attempts = 0;

-- 4. Bind the High-Frequency 30-Second Schedule Matrix
EXEC msdb.dbo.sp_add_jobschedule     
    @job_id = @jobId, 
    @name = N'Timesheet_30Sec_Interval',
    @enabled = 1,
    @freq_type = 4,                -- Daily
    @freq_interval = 1,            -- Every 1 Day
    @freq_subday_type = 2,         -- Subday Units: Seconds
    @freq_subday_interval = 30,    -- Interval Step: 30 Seconds
    @active_start_time = 000000;   -- Midnight
GO

-- 5. Attach to Target Server Node Context
DECLARE @jobId BINARY(16);
SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE name = N'Run_Timesheet_Package';
EXEC msdb.dbo.sp_add_jobserver     
    @job_id = @jobId, 
    @server_name = @@SERVERNAME;
GO