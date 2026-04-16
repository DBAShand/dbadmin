USE [master]
GO
CREATE LOGIN [scs\_SQL_prxMon_svc] FROM WINDOWS WITH DEFAULT_DATABASE=[DBAdmin], DEFAULT_LANGUAGE=[us_english]
GO
USE [DBAdmin]
GO
CREATE USER [scs\_SQL_prxMon_svc] FOR LOGIN [scs\_SQL_prxMon_svc]
GO
USE [DBAdmin]
GO
ALTER ROLE [db_datareader] ADD MEMBER [scs\_SQL_prxMon_svc]
GO
USE [DBAdmin]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [scs\_SQL_prxMon_svc]
GO
USE [DBAdmin]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [scs\_SQL_prxMon_svc]
GO
USE [DBAdmin]
GO
ALTER ROLE [db_developer] ADD MEMBER [scs\_SQL_prxMon_svc]
GO
USE [DBAdmin]
GO
ALTER ROLE [db_executor] ADD MEMBER [scs\_SQL_prxMon_svc]
GO
