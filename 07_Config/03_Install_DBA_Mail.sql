

USE [master]
GO
sp_configure 'show advanced options',1
GO
RECONFIGURE WITH OVERRIDE
GO
sp_configure 'Database Mail XPs',1
GO
RECONFIGURE 
GO

DECLARE @Profile NVARCHAR(50)
DECLARE @Account NVARCHAR(50)
DECLARE @Email NVARCHAR(100)
DECLARE @Display NVARCHAR(50)

SET @Profile = (SELECT @@SERVERNAME)
SET @Account = (SELECT @@SERVERNAME) + ' Alerts'
SET @Email = REPLACE(@Profile, '-', '_')
SET @Email = REPLACE(@Email, '\', '_') + '@VU.com'
--SET @Display = RIGHT(@Profile, LEN(@Profile) - 7)
SET @Display = REPLACE(@Profile, '-', ' ')
SET @Display = REPLACE(@Display, '\', ' ') + ' Instance'

--PRINT @Profile
--PRINT @Account
--PRINT @Email
--PRINT @Display

-- Create a New Mail Profile for Notifications
EXECUTE msdb.dbo.sysmail_add_profile_sp
       @profile_name = @Profile,
       @description = 'Alerts Email'

-- Set the New Profile as the Default
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = @Profile,
    @principal_name = 'public',
    @is_default = 1 ;

-- Create an Account for the Notifications
EXECUTE msdb.dbo.sysmail_add_account_sp
    @account_name = @Account,
    @description = 'Alerts Email',
    @email_address = @Email,
    @display_name = @Display,
	@replyto_address = 'it_dba@VU.com',
    @mailserver_name = 'smtp.veteransunited.com'

-- Add the Account to the Profile
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = @Profile,
    @account_name = @Account,
    @sequence_number = 1
GO

USE [msdb]
GO
EXEC master.dbo.sp_MSsetalertinfo @failsafeoperator=N'DBA Group', 
		@notificationmethod=1
GO
USE [msdb]
GO

DECLARE @ServerName AS NVARCHAR(50)
SET @ServerName = (SELECT @@SERVERNAME)
EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder=1, 
		@alert_replace_runtime_tokens=1, 
		@databasemail_profile=@ServerName, 
		@use_databasemail=1
GO

DECLARE @PROFILE VARCHAR(MAX) = (SELECT name FROM dbo.sysmail_profile)
DECLARE @bodytext VARCHAR(MAX) = 'SET UP DBMAIL for ' + @@servername 
EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = @profile,  
    @recipients = 'dba@vu.com',  
    @body = @bodytext,  
    @subject = 'Automated Success Message' ;  