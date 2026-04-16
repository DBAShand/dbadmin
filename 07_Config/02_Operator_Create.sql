USE [msdb]
GO

EXEC msdb.dbo.sp_add_operator @name=N'DBA Group', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'it_dba@veteransunited.com', 
		@category_name=N'[Uncategorized]'
GO


USE [msdb]
GO

EXEC msdb.dbo.sp_add_operator @name=N'DBA_OnCall', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'it_dba@veteransunited.com; ', 
		@category_name=N'[Uncategorized]'
GO


