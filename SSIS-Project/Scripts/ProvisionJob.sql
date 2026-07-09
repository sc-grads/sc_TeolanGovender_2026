USE [msdb];
GO

SET NOCOUNT ON;

-- 1. Clear Out Stale Existing Job Definitions
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'$(TARGET_JOB_NAME)')
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
    DECLARE @real_package_name NVARCHAR(100);
    DECLARE @server_name NVARCHAR(100) = @@SERVERNAME;
    
    -- Dynamically isolate the correct database engine playground target context
    DECLARE @target_db NVARCHAR(50) = CASE 
        WHEN N''$(CATALOG_FOLDER)'' LIKE ''%Production%'' THEN N''TimesheetTGDB''
        ELSE N''TimesheetDB''
    END;

    -- Grab the correct root folder path parameter dynamically matching your layout
    SELECT TOP 1 @resolved_path = CONVERT(NVARCHAR(255), op.default_value)
    FROM [SSISDB].[catalog].[object_parameters] op
    INNER JOIN [SSISDB].[catalog].[projects] p ON op.project_id = p.project_id
    INNER JOIN [SSISDB].[catalog].[folders] f ON p.folder_id = f.folder_id
    WHERE f.name = N''$(CATALOG_FOLDER)''
      AND p.name = N''$(PROJECT_NAME)''
      AND op.parameter_name = N''RootFolder'';

    -- Dynamically find the real package name deployed inside this specific execution environment
    SELECT TOP 1 @real_package_name = pk.name
    FROM [SSISDB].[catalog].[packages] pk
    INNER JOIN [SSISDB].[catalog].[projects] p ON pk.project_id = p.project_id
    INNER JOIN [SSISDB].[catalog].[folders] f ON p.folder_id = f.folder_id
    WHERE f.name = N''$(CATALOG_FOLDER)''
      AND p.name = N''$(PROJECT_NAME)'';

    -- Create execution instance using the freshly discovered real catalog names
    EXEC [SSISDB].[catalog].[create_execution] 
        @folder_name = N''$(CATALOG_FOLDER)'', 
        @project_name = N''$(PROJECT_NAME)'', 
        @package_name = @real_package_name, 
        @reference_id = NULL, 
        @use32bitruntime = FALSE, 
        @execution_id = @execution_id OUTPUT;

    -- Apply the RootFolder directory parameter override string to the execution scope
    IF @resolved_path IS NOT NULL
    BEGIN
        DECLARE @path_variant SQL_VARIANT = CAST(@resolved_path AS NVARCHAR(4000));
        EXEC [SSISDB].[catalog].[set_execution_parameter_value] 
            @execution_id, 
            @object_type = 20, 
            @parameter_name = N''RootFolder'', 
            @parameter_value = @path_variant;
    END;

    -- FIXED: Changed from NVARCHAR(MAX) to NVARCHAR(4000) to resolve sql_variant type clash (Error 206)
    DECLARE @conn_string_db NVARCHAR(4000) = N''Data Source='' + @server_name + '';Initial Catalog='' + @target_db + '';Provider=SQLNCLI11.1;Integrated Security=SSPI;Auto Translate=False;'';
    DECLARE @conn_variant SQL_VARIANT = CAST(@conn_string_db AS NVARCHAR(4000));
    
    EXEC [SSISDB].[catalog].[set_execution_parameter_value] 
        @execution_id, @object_type = 50, @parameter_name = N''LocalHost.TimesheetDB'', @parameter_value = @conn_variant;

    EXEC [SSISDB].[catalog].[set_execution_parameter_value] 
        @execution_id, @object_type = 50, @parameter_name = N''LocalHost.TimesheetCMDB'', @parameter_value = @conn_variant;

    -- Launch package execution cleanly
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