USE [master]
GO
CREATE LOGIN [scs\_DBAdmin_P] FROM WINDOWS WITH DEFAULT_DATABASE=[DBAdmin]
GO
USE [DBAdmin]
GO
CREATE USER [scs\_DBAdmin_P] FOR LOGIN [scs\_DBAdmin_P]
GO
USE [DBAdmin]
GO
ALTER ROLE [db_datareader] ADD MEMBER [scs\_DBAdmin_P]
GO
USE [DBAdmin]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [scs\_DBAdmin_P]
GO
