-- ============================================================
-- 13_SQLProxyAccount.sql
-- Creates the SQL monitoring proxy service account login
-- and grants it the appropriate roles in DBAdmin.
--
-- POWERSHELL TOKENS (replace before running):
--   {{DOMAIN}}            e.g. CONTOSO
--   {{PROXY_ACCOUNT}}     e.g. svc_sqlprxmon
-- ============================================================

USE [master]
GO

DECLARE @login SYSNAME = N'{{DOMAIN}}\{{PROXY_ACCOUNT}}'

IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = @login)
BEGIN
    DECLARE @sql NVARCHAR(MAX) =
        'CREATE LOGIN [' + @login + '] FROM WINDOWS WITH DEFAULT_DATABASE=[DBAdmin], DEFAULT_LANGUAGE=[us_english]'
    EXEC (@sql)
    PRINT 'Login created: ' + @login
END
ELSE
    PRINT 'Login already exists: ' + @login
GO

USE [DBAdmin]
GO

DECLARE @login SYSNAME = N'{{DOMAIN}}\{{PROXY_ACCOUNT}}'

IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = @login)
BEGIN
    DECLARE @sql NVARCHAR(MAX) = 'CREATE USER [' + @login + '] FOR LOGIN [' + @login + ']'
    EXEC (@sql)
    PRINT 'User created: ' + @login
END
ELSE
    PRINT 'User already exists: ' + @login

ALTER ROLE [db_datareader] ADD MEMBER [{{DOMAIN}}\{{PROXY_ACCOUNT}}]
ALTER ROLE [db_datawriter] ADD MEMBER [{{DOMAIN}}\{{PROXY_ACCOUNT}}]
ALTER ROLE [db_ddladmin]   ADD MEMBER [{{DOMAIN}}\{{PROXY_ACCOUNT}}]
ALTER ROLE [db_developer]  ADD MEMBER [{{DOMAIN}}\{{PROXY_ACCOUNT}}]
ALTER ROLE [db_executor]   ADD MEMBER [{{DOMAIN}}\{{PROXY_ACCOUNT}}]
GO

PRINT 'Proxy account setup complete.'
GO
