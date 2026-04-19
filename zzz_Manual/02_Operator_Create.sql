-- ============================================================
-- 02_Operator_Create.sql
-- Creates SQL Agent operators for alerting.
--
-- POWERSHELL TOKENS (replace before running):
--   {{DBA_EMAIL}}       e.g. dba@contoso.com
--   {{ONCALL_EMAIL}}    e.g. oncall@contoso.com
-- ============================================================

USE [msdb]
GO

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysoperators WHERE name = N'DBA Group')
BEGIN
    EXEC msdb.dbo.sp_add_operator
        @name                      = N'DBA Group',
        @enabled                   = 1,
        @weekday_pager_start_time  = 90000,
        @weekday_pager_end_time    = 180000,
        @saturday_pager_start_time = 90000,
        @saturday_pager_end_time   = 180000,
        @sunday_pager_start_time   = 90000,
        @sunday_pager_end_time     = 180000,
        @pager_days                = 0,
        @email_address             = N'{{DBA_EMAIL}}',
        @category_name             = N'[Uncategorized]'
    PRINT 'Operator [DBA Group] created.'
END
ELSE
    PRINT 'Operator [DBA Group] already exists, skipping.'
GO

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysoperators WHERE name = N'DBA_OnCall')
BEGIN
    EXEC msdb.dbo.sp_add_operator
        @name                      = N'DBA_OnCall',
        @enabled                   = 1,
        @weekday_pager_start_time  = 90000,
        @weekday_pager_end_time    = 180000,
        @saturday_pager_start_time = 90000,
        @saturday_pager_end_time   = 180000,
        @sunday_pager_start_time   = 90000,
        @sunday_pager_end_time     = 180000,
        @pager_days                = 0,
        @email_address             = N'{{ONCALL_EMAIL}}',
        @category_name             = N'[Uncategorized]'
    PRINT 'Operator [DBA_OnCall] created.'
END
ELSE
    PRINT 'Operator [DBA_OnCall] already exists, skipping.'
GO
