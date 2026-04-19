-- ============================================================
-- 03_Install_DBA_Mail.sql
-- Configures Database Mail profile, account, and SQL Agent
-- to use it for alerting.
--
-- POWERSHELL TOKENS (replace before running):
--   {{SMTP_SERVER}}     e.g. smtp.contoso.com
--   {{REPLYTO_EMAIL}}   e.g. dba@contoso.com
-- ============================================================

USE [master]
GO

-- Enable Database Mail and show advanced options
EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sp_configure 'Database Mail XPs', 1
GO
RECONFIGURE
GO

-- Derive profile/account/display names and email from server name
DECLARE @Profile    NVARCHAR(50)  = @@SERVERNAME
DECLARE @Account    NVARCHAR(50)  = @@SERVERNAME + ' Alerts'
DECLARE @Email      NVARCHAR(100) = REPLACE(REPLACE(@@SERVERNAME, '-', '_'), '\', '_') + '@{{SMTP_DOMAIN}}'
DECLARE @Display    NVARCHAR(50)  = REPLACE(REPLACE(@@SERVERNAME, '-', ' '), '\', ' ') + ' Instance'
DECLARE @SMTPServer NVARCHAR(100) = N'{{SMTP_SERVER}}'
DECLARE @ReplyTo    NVARCHAR(100) = N'{{REPLYTO_EMAIL}}'

-- Create mail profile
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysmail_profile WHERE name = @Profile)
BEGIN
    EXEC msdb.dbo.sysmail_add_profile_sp
        @profile_name = @Profile,
        @description  = 'Alerts Email'
    PRINT 'Mail profile created: ' + @Profile
END
ELSE
    PRINT 'Mail profile already exists: ' + @Profile

-- Set as default profile for public
EXEC msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name    = @Profile,
    @principal_name  = 'public',
    @is_default      = 1

-- Create mail account
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysmail_account WHERE name = @Account)
BEGIN
    EXEC msdb.dbo.sysmail_add_account_sp
        @account_name      = @Account,
        @description       = 'Alerts Email',
        @email_address     = @Email,
        @display_name      = @Display,
        @replyto_address   = @ReplyTo,
        @mailserver_name   = @SMTPServer
    PRINT 'Mail account created: ' + @Account
END
ELSE
    PRINT 'Mail account already exists: ' + @Account

-- Add account to profile
EXEC msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name    = @Profile,
    @account_name    = @Account,
    @sequence_number = 1
GO

-- Set failsafe operator
USE [msdb]
GO
EXEC master.dbo.sp_MSsetalertinfo
    @failsafeoperator    = N'DBA Group',
    @notificationmethod  = 1
GO

-- Configure SQL Agent to use Database Mail
DECLARE @ServerName SYSNAME = @@SERVERNAME
EXEC msdb.dbo.sp_set_sqlagent_properties
    @email_save_in_sent_folder    = 1,
    @alert_replace_runtime_tokens = 1,
    @databasemail_profile         = @ServerName,
    @use_databasemail             = 1
GO

-- Send test message to confirm setup
DECLARE @Profile   VARCHAR(MAX) = (SELECT name FROM msdb.dbo.sysmail_profile)
DECLARE @bodytext  VARCHAR(MAX) = 'DBMail setup complete on ' + @@SERVERNAME
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = @Profile,
    @recipients   = '{{REPLYTO_EMAIL}}',
    @body         = @bodytext,
    @subject      = 'DBMail Setup - Automated Success Message'
GO
