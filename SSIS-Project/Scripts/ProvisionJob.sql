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

-- 3. Add Execution Step Target explicitly pointing at Package2.dtsx
DECLARE @ssisCommand NVARCHAR(4000) = N'/ISSERVER "\"\SSISDB\PracticeActivities\TimesheetIntegrationTestTwo\Package2.dtsx\"" /SERVER "." /EnforceObjectType';

EXEC msdb.dbo.sp_add_jobstep 
    @job_id = @jobId, 
    @step_name = N'Run Integrated Package Process',
    @subsystem = N'SSIS',
    @command = @ssisCommand,
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