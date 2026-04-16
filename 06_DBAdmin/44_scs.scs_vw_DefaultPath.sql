USE DBADMIN
GO
CREATE VIEW scs.scs_vw_DefaultPath
as
SELECT 
	DataPath = SERVERPROPERTY('InstanceDefaultDataPath')
   ,LogPath = SERVERPROPERTY('InstanceDefaultLogPath')
GO


