USE [msdb]
GO

/****** Object:  Job [scs_Index_Monitor]    Script Date: 2/20/2017 10:39:30 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 2/20/2017 10:39:30 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'scs_Index_Monitor', 
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
/****** Object:  Step [scs_Index_Maint]    Script Date: 2/20/2017 10:39:31 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'scs_Index_Maint', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
DECLARE @databases TABLE
       (
              rowID INT IDENTITY(1,1)
              ,command NVARCHAR(MAX)
       )


       INSERT INTO @databases
       SELECT 
              ''use  ['' + a.name + '']
			  insert into DBADMIN.scs.INDEXTEMP
				SELECT	db_name(DB_ID()),
						dbtables.[name] as ''''Table'''',
						dbindexes.[name] as ''''Index'''',
						indexstats.avg_fragmentation_in_percent,
						indexstats.page_count,
						dbindexes.fill_factor,
						getdate()
						FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
						INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
						INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
						INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
						AND indexstats.index_id = dbindexes.index_id
						WHERE --indexstats.database_id = DB_ID() 
						indexstats.avg_fragmentation_in_percent > 0
						and indexstats.page_count > 1000
						ORDER BY indexstats.avg_fragmentation_in_percent desc''
    FROM dbadmin.scs.scs_vw_VU_User_DBs a
	JOIn  dbadmin.scs.scs_vw_DBInfoExtended b ON a. dbid = b.database_id AND Status = ''ONLINE''
       DECLARE @databasesCounter INT
       DECLARE @maxRowID_LSJobs INT
       DECLARE @Command NVARCHAR(MAX)
SELECT @maxRowID_LSJobs = MAX(rowID) 
       FROM @databases

       SET @databasesCounter = 1

       WHILE @databasesCounter <= @maxRowID_LSJobs
              BEGIN
                     Select @Command = command
                     FROM @databases
                     WHERE rowID = @databasesCounter

                     EXECUTE sp_executesql @Command
                     PRINT @Command
       
                     SET @databasesCounter = @databasesCounter + 1

              END
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 4 Hours', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=4, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20161107, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'0ced3730-31e1-4af2-a3e5-3f7dfa1581c8'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


