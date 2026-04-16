USE [msdb]
GO

/****** Object:  Job [scs_Disable_Backup_Check]    Script Date: 3/29/2017 10:47:35 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 3/29/2017 10:47:35 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'scs_Disable_Backup_Check', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [scs_RUN_CHECK]    Script Date: 3/29/2017 10:47:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'scs_RUN_CHECK', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @query nvarchar(max)
DECLARE @profile nvarchar(max)
DECLARE @MSG NVARCHAR(MAX)
DECLARE @HTML NVARCHAR(MAX)
SET @profile = (select @@servername)

CREATE TABLE ##jobs
       (
              rowID INT IDENTITY(1,1)
			  ,name sysname
              ,command NVARCHAR(MAX)
			  
       )


       INSERT INTO ##jobs
       SELECT name,
              ''EXEC msdb.dbo.sp_update_job @job_name=N'''''' + name + '''''', @enabled= 1''
			  FROM msdb.dbo.sysjobs 
WHERE name LIKE (''DatabaseBackup%'') AND enabled = 0
       DECLARE @jobCounter INT
       DECLARE @maxRowID_LSJobs INT
       DECLARE @Command NVARCHAR(MAX)

       SELECT @maxRowID_LSJobs = MAX(rowID) 
       FROM ##jobs

       SET @jobCounter = 1

       WHILE @jobCounter <= @maxRowID_LSJobs
              BEGIN
                     Select @Command = command
                     FROM ##jobs
                     WHERE rowID = @jobCounter

                     EXECUTE sp_executesql @Command
      
                     SET @jobCounter = @jobCounter + 1

              END


SET @query = ''SELECT name FROM ##jobs'' 
SET @MSG = ''The jobs listed below were disabled.  They have been enabled!''
EXEC dbadmin.scs.scs_spQueryToHtmlTable @html = @html OUTPUT, @count = @JobCounter OUTPUT, @msg = @MSG, @query = @query


PRINT @jobCounter
IF @JobCounter > 0
Begin
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = @profile,
    @recipients = ''dba@vu.com'',
    @subject =''Job Disabled'',
    @body = @html,
    @body_format = ''HTML'',
    @query_no_truncate = 1,
    @attach_query_result_as_file = 0;
END

DROP table ##jobs', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 30 Min', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170324, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'effe0ef6-6927-49a0-9ab1-28bc56e05f79'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


