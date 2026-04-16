USE [msdb]
GO

/****** Object:  Job [scs_Full_Backup_Report]    Script Date: 2/21/2017 9:56:01 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 2/21/2017 9:56:01 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'scs_Full_Backup_Report', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA Group', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [scs_Full_Backup_Latency]    Script Date: 2/21/2017 9:56:01 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'scs_Full_Backup_Latency', 
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
DECLARE @results nvarchar(max)
DECLARE @results2 nvarchar(max)
DECLARE @profile nvarchar(max)
DECLARE @count inT
DECLARE @MSG NVARCHAR(MAX)
DECLARE @HTML NVARCHAR(MAX)
SET @profile = (select @@servername)

SET @query = 
''select a.dbname as [Database Name]
      ,a.recovery_model_desc [Recovery Model]
      ,a.backup_type_desc  as [Backup Type]
	 ,rb.rbrecient_backup [Last Backup]
	  ,datediff(day,rb.rbrecient_backup,getdate()) [Days Since Last Backup]
	  ,a.backup_in_min [Backup Duration]
	  ,a.backup_size_in_MB [Backup Size (MB)]
	 from dbadmin.scs.scs_vw_Backupinfo a 
join 
(select z.dbname as dbname
	, max(z.backup_start_date) as rbrecient_backup
from dbadmin.scs.scs_vw_Backupinfo z
join dbadmin.scs.scs_vw_DbInfo y on z.dbname = y.dbname
join dbadmin.scs.scs_vw_VU_USER_DBs x on z.DBName = x.name
where (y.AG_Role = 1)  or (AG_NAME is Null and Y.Status = ''''ONLINE'''') AND z.backup_type = ''''D''''
group by z.dbname) as rb on a.dbname = rb.dbname
where a.backup_type = ''''D'''' and datediff(Day,rb.rbrecient_backup,getdate()) > 7''

SET @MSG = ''Databases not backed up in 7 Days''
EXEC dbadmin.scs.scs_spQueryToHtmlTable @html = @html OUTPUT, @count = @count OUTPUT, @msg = @MSG, @query = @query
IF @count > 0
Begin
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = @profile,
    @recipients = ''dba@vu.com'',
    @subject =''Full Backup Latency'',
    @body = @html,
    @body_format = ''HTML'',
    @query_no_truncate = 1,
    @attach_query_result_as_file = 0;
End', 
		@database_name=N'DBAdmin', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'scs_Full_Backup_Latency', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160902, 
		@active_end_date=99991231, 
		@active_start_time=70000, 
		@active_end_time=235959, 
		@schedule_uid=N'f749e7b4-6547-4cd2-b1a3-e916b821b129'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


