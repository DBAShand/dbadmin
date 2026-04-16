USE [DBAdmin]
GO

/****** Object:  StoredProcedure [scs].[scs_BackupRestoreEstCompTime]    Script Date: 4/5/2017 12:30:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[scs].[scs_BackupRestoreEstCompTime]') AND type IN (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [scs].[scs_BackupRestoreEstCompTime] AS' 
END
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [scs].[scs_BackupRestoreEstCompTime]
AS
BEGIN
SELECT
	session_id,
	start_time,
	status,
	command,
	percent_complete,
	estimated_completion_time,
	estimated_completion_time /60/1000 AS estimate_completion_minutes,
	--(select convert(varchar(5),getdate(),8)),
	DATEADD(n,(estimated_completion_time /60/1000),GETDATE()) AS estimated_completion_time

FROM    sys.dm_exec_requests WHERE command = 'BACKUP DATABASE' OR command = 'RESTORE DATABASE'
END


GO


