USE [msdb];
GO
SET NOCOUNT ON;

-- Dynamically configure naming variables based on server layout environment context
DECLARE @targetJobName NVARCHAR(100);
DECLARE @catalogFolder NVARCHAR(100);
DECLARE @projectName NVARCHAR(100);
DECLARE @targetFilePath NVARCHAR(255);

IF @@SERVERNAME LIKE '%DEV%' OR @@SERVERNAME LIKE '%LOCAL%' -- Adjust keywords to match her server name properties
BEGIN
    -- Production (Partner's Named Instance Layout)
    SET @targetJobName = N'RunTimesheetProductionMigrationPK';
    SET @catalogFolder = N'TimesheetProductionMigration';
    SET @projectName = N'TimesheetProductionMigrationPK';
    SET @targetFilePath = N'c:\sc_CharmaneMchunu_2026\SSIS-Project-TG\Timesheets\';
END
ELSE
BEGIN
    -- Local Staging
    SET @targetJobName = N'RunTimesheetDevTestMigrationPK';
    SET @catalogFolder = N'TimesheetDevTestMigration';
    SET @projectName = N'TimesheetDevTestMigrationPK';
    SET @targetFilePath = N'C:\sc_TeolanGovender_2026\SSIS-Project\Timesheets\';
END

-- 1. Clear out existing job definition safely
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = @targetJobName)
BEGIN
    EXEC msdb.dbo.sp_delete_job @job_name = @targetJobName, @delete_unused_schedule = 1;
END;

-- 2. Provision the core automated agent 
DECLARE @jobId BINARY(16);
EXEC msdb.dbo.sp_add_job     
    @job_name = @targetJobName, 
    @enabled = 1, 
    @job_id = @jobId OUTPUT;

-- 3. Prepare the engine execution payload
DECLARE @tsqlCommand NVARCHAR(MAX) = N'
    DECLARE @execution_id BIGINT;
    
    EXEC [SSISDB].[catalog].[create_execution] 
        @folder_name = N''' + @catalogFolder + ''', 
        @project_name = N''' + @projectName + ''', 
        @package_name = N''Package2.dtsx'', -- ◄ Ensure your .dtsx layout match filename inside Visual Studio
        @reference_id = NULL, 
        @use32bitruntime = FALSE, 
        @execution_id = @execution_id OUTPUT;
    
    BEGIN TRY
        EXEC [SSISDB].[catalog].[set_execution_parameter_value] 
            @execution_id, @object_type = 20, @parameter_name = N''Source_File_Directory'', @parameter_value = N''' + @targetFilePath + ''';
    END TRY
    BEGIN CATCH
        EXEC [SSISDB].[catalog].[set_execution_parameter_value] 
            @execution_id, @object_type = 30, @parameter_name = N''Project::Source_File_Directory'', @parameter_value = N''' + @targetFilePath + ''';
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