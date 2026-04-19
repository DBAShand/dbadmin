-- ============================================================
-- 05_DBAdmin_User_Create.sql
-- Creates the DBAdmin database user mapped to a Windows login.
--
-- POWERSHELL TOKENS (replace before running):
--   {{DBADMIN_LOGIN}}   Windows login, e.g. DOMAIN\svc_sqldba
-- ============================================================

USE [master]
GO

IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = N'{{DBADMIN_LOGIN}}')
BEGIN
    CREATE LOGIN [{{DBADMIN_LOGIN}}] FROM WINDOWS WITH DEFAULT_DATABASE=[DBAdmin]
    PRINT 'Login created: {{DBADMIN_LOGIN}}'
END
ELSE
    PRINT 'Login already exists: {{DBADMIN_LOGIN}}'
GO

USE [DBAdmin]
GO

IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = N'{{DBADMIN_LOGIN}}')
BEGIN
    CREATE USER [{{DBADMIN_LOGIN}}] FOR LOGIN [{{DBADMIN_LOGIN}}]
    PRINT 'User created in DBAdmin: {{DBADMIN_LOGIN}}'
END
ELSE
    PRINT 'User already exists in DBAdmin: {{DBADMIN_LOGIN}}'
GO

ALTER ROLE [db_datareader] ADD MEMBER [{{DBADMIN_LOGIN}}]
ALTER ROLE [db_datawriter] ADD MEMBER [{{DBADMIN_LOGIN}}]
GO
