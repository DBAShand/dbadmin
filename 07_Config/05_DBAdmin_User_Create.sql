USE [master]
GO
CREATE LOGIN [tochange FROM WINDOWS WITH DEFAULT_DATABASE=[DBAdmin]
GO
USE [DBAdmin]
GO
CREATE USER [scs_DBAdmin_P] FOR LOGIN [tochange]
GO
USE [DBAdmin]
GO
ALTER ROLE [db_datareader] ADD MEMBER [scs_DBAdmin_P]
GO
USE [DBAdmin]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [scs_DBAdmin_P]
GO
