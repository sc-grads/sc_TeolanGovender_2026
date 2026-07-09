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

-- 3. Prepare the Diagnostic T-SQL Payload
DECLARE @tsqlCommand NVARCHAR(MAX) = N'
    DECLARE @resolved_path NVARCHAR(255);
    DECLARE @resolved_package_name NVARCHAR(255);
    DECLARE @resolved_project_name NVARCHAR(255);

    -- Diagnostic 1: Grab project name
    SELECT TOP 1 @resolved_project_name = p.name
    FROM [SSISDB].[catalog].[projects] p
    INNER JOIN [SSISDB].[catalog].[folders] f ON p.folder_id = f.folder_id
    WHERE f.name = N''$(CATALOG_FOLDER)'';

    -- Diagnostic 2: Grab path parameter 
    SELECT TOP 1 @resolved_path = CONVERT(NVARCHAR(255), op.design_default_value)
    FROM [SSISDB].[catalog].[object_parameters] op
    INNER JOIN [SSISDB].[catalog].[projects] p ON op.project_id = p.project_id
    INNER JOIN [SSISDB].[catalog].[folders] f ON p.folder_id = f.folder_id
    WHERE f.name = N''$(CATALOG_FOLDER)''
      AND op.parameter_name = N''Source_File_Directory'';

    -- Diagnostic 3: Grab package filename
    SELECT TOP 1 @resolved_package_name = pkg.name
    FROM [SSISDB].[catalog].[packages] pkg
    INNER JOIN [SSISDB].[catalog].[projects] p ON pkg.project_id = p.project_id
    INNER JOIN [SSISDB].[catalog].[folders] f ON p.folder_id = f.folder_id
    WHERE f.name = N''$(CATALOG_FOLDER)'';

    -- Force an explicit error message displaying what was discovered
    DECLARE @ErrorMessage NVARCHAR(MAX);
    SET @ErrorMessage = CHAR(13) + CHAR(10) + 
                        N''=== SSIS EXECUTOR DIAGNOSTICS ==='' + CHAR(13) + CHAR(10) +
                        N''Target Folder:  [$(CATALOG_FOLDER)]'' + CHAR(13) + CHAR(10) +
                        N''Found Project:  ['' + ISNULL(@resolved_project_name, ''NULL'') + '']'' + CHAR(13) + CHAR(10) +
                        N''Found Package:  ['' + ISNULL(@resolved_package_name, ''NULL'') + '']'' + CHAR(13) + CHAR(10) +
                        N''Found FilePath: ['' + ISNULL(@resolved_path, ''NULL'') + '']'' + CHAR(13) + CHAR(10) +
                        N''==============================='';
    
    RAISERROR(@ErrorMessage, 16, 1);
';

EXEC msdb.dbo.sp_add_jobstep         
    @job_id = @jobId, 
    @step_name = N'Run Integrated Package Process',
    @subsystem = N'TSQL',
    @database_name = N'master',
    @command = @tsqlCommand,
    @retry_attempts = 0;

-- 5. Attach to Target Server Context
EXEC msdb.dbo.sp_add_jobserver         
    @job_id = @jobId, 
    @server_name = @@SERVERNAME;
GO