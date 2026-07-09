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
DECLARE @tsqlCommand NVARCHAR(MAX) = N'
    DECLARE @execution_id BIGINT;
    DECLARE @resolved_path NVARCHAR(255);
    DECLARE @resolved_package_name NVARCHAR(255);
    DECLARE @resolved_project_name NVARCHAR(255);

    -- 1. Dynamically grab the project name that actually exists inside this folder context
    SELECT TOP 1 @resolved_project_name = p.name
    FROM [SSISDB].[catalog].[projects] p
    INNER JOIN [SSISDB].[catalog].[folders] f ON p.folder_id = f.folder_id
    WHERE f.name = N''$(CATALOG_FOLDER)'';

    -- Fallback project name safety rule if folder query is blank
    IF @resolved_project_name IS NULL
    BEGIN
        SET @resolved_project_name = N''$(PROJECT_NAME)'';
    END

    -- 2. Grab the path parameter that Step 9 successfully updated using the resolved project
    SELECT TOP 1 @resolved_path = CONVERT(NVARCHAR(255), op.design_default_value)
    FROM [SSISDB].[catalog].[object_parameters] op
    INNER JOIN [SSISDB].[catalog].[projects] p ON op.project_id = p.project_id
    INNER JOIN [SSISDB].[catalog].[folders] f ON p.folder_id = f.folder_id
    WHERE f.name = N''$(CATALOG_FOLDER)''
      AND p.name = @resolved_project_name
      AND op.parameter_name = N''Source_File_Directory'';

    -- 3. Dynamically grab the package filename using ONLY the catalog folder name context
    SELECT TOP 1 @resolved_package_name = pkg.name
    FROM [SSISDB].[catalog].[packages] pkg
    INNER JOIN [SSISDB].[catalog].[projects] p ON pkg.project_id = p.project_id
    INNER JOIN [SSISDB].[catalog].[folders] f ON p.folder_id = f.folder_id
    WHERE f.name = N''$(CATALOG_FOLDER)'';

    -- 4. Fallback environment-aware safety check if metadata query returns blank
    IF @resolved_package_name IS NULL
    BEGIN
        IF N''$(CATALOG_FOLDER)'' = N''TimesheetProductionMigration''
            SET @resolved_package_name = N''TimesheetProductionMigrationPK.dtsx'';
        ELSE
            SET @resolved_package_name = N''TimesheetDevTestMigrationPK.dtsx'';
    END
        
    -- 5. Create the execution instance in the SSIS catalog using the fully resolved name values
    EXEC [SSISDB].[catalog].[create_execution] 
        @folder_name = N''$(CATALOG_FOLDER)'', 
        @project_name = @resolved_project_name, 
        @package_name = @resolved_package_name, 
        @reference_id = NULL, 
        @use32bitruntime = FALSE, 
        @execution_id = @execution_id OUTPUT;
        
    -- 6. Dynamically apply the fetched path parameter to the execution run
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