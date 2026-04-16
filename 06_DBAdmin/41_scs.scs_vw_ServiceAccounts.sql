USE [DBAdmin]
GO
CREATE VIEW [scs].[scs_vw_ServiceAccounts]
AS
SELECT        servicename, service_account, last_startup_time
FROM            sys.dm_server_services

GO


