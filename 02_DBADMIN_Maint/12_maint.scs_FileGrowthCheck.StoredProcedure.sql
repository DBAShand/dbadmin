USE [DBAdmin]
GO

/****** Object:  StoredProcedure [maint].[scs_FileGrowthCheck]    Script Date: 4/5/2017 2:37:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[maint].[scs_FileGrowthCheck]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [maint].[scs_FileGrowthCheck] AS' 
END
GO




ALTER PROCEDURE [maint].[scs_FileGrowthCheck]
AS
BEGIN
	SET NOCOUNT ON;

	
		DECLARE @FileName NVARCHAR(MAX)
	DECLARE @DBName NVARCHAR(MAX)
	DECLARE @FileSize DECIMAL(5,2)
	DECLARE @RowID INT
	DECLARE @Growth INT
	DECLARE @sql NVARCHAR(MAX)
	DECLARE @html NVARCHAR(MAX)
	DECLARE @profile nvarchar(max)
	SET @profile = (select @@servername)
	DECLARE @Status NVARCHAR(20)
	DECLARE @FileType NVARCHAR(15)
	DECLARE @FileState NVARCHAR(15)
	DECLARE @AGRepState NVARCHAR(15)
	

	IF OBJECT_ID('tempdb..#TempDBFiles') IS NOT NULL
	DROP TABLE #TempDBFiles

	IF OBJECT_ID('tempdb..#TempDBFilesAll') IS NOT NULL
	DROP TABLE #TempDBFilesAll

	IF OBJECT_ID('tempdb..#TempDBFilesSingle') IS NOT NULL
	DROP TABLE #TempDBFilesSingle

	CREATE TABLE #TempDBFiles
		(RowID int IDENTITY(1,1) NOT NULL,
		DBName NVARCHAR(100),
		NAME NVARCHAR(100),
		Size_GBs DECIMAL(5,2),
		Growth INT,
		FileType NVARCHAR(15))

	CREATE TABLE #TempDBFilesAll
		(DBName NVARCHAR(100),
		[FileName] NVARCHAR(100),
		OldGrowth DECIMAL(9,2),
		NewGrowth INT)

	CREATE TABLE #TempDBFilesSingle
		(DBName NVARCHAR(100),
		[FileName] NVARCHAR(100),
		Growth DECIMAL(9,2),
		FileType NVARCHAR(15),
		FileState NVARCHAR(15))

	INSERT INTO #TempDBFiles(DBName, name, Size_GBs, Growth, FileType)
	SELECT
	DB_NAME(mf.database_id) DBName,
	name,
	CONVERT(DECIMAL(10,2),((size * 8.00) / 1024.00 / 1024)) AS Size_GBs,
	mf.growth/128 Growth,
	mf.type_desc
	FROM sys.master_files mf

	--SELECT * FROM #TempDBFiles

	WHILE (SELECT COUNT(DBName) FROM #TempDBFiles) >0
		BEGIN
			SET @sql = ''
			SET @RowID = (SELECT TOP 1 RowID FROM #TempDBFiles ORDER BY RowID)
			SET @FileName = (SELECT TOP 1 name FROM #TempDBFiles WHERE RowID = @RowID)
			SET @DBName = (SELECT TOP 1 DBName FROM #TempDBFiles WHERE RowID = @RowID)
			SET @FileSize = (SELECT TOP 1 Size_GBs FROM #TempDBFiles WHERE RowID = @RowID)
			SET @Status = (SELECT state_desc FROM sys.databases WHERE name = @DBName)
			SET @FileState = (SELECT state_desc FROM sys.databases WHERE name = @DBName)

			DELETE FROM #TempDBFiles WHERE DBName IN (SELECT DISTINCT database_name FROM sys.availability_replicas
								LEFT JOIN sys.availability_groups ON availability_groups.group_id = availability_replicas.group_id
								RIGHT JOIN sys.dm_hadr_database_replica_cluster_states ON dm_hadr_database_replica_cluster_states.replica_id = availability_replicas.replica_id WHERE secondary_role_allow_connections_desc = 'READ_ONLY' OR secondary_role_allow_connections_desc = 'NO')
			IF @FileState = 'Online'
				BEGIN
					SET @sql = 'USE [' + @DBName + '] INSERT INTO #TempDBFilesSingle 
					SELECT ''[' + @DBName + ']'', name, growth/128 as growth, type_desc, state_desc FROM sys.database_files WHERE name = ''' + @FileName + ''''
					EXEC sys.sp_executesql @sql
				END
			SET @Growth = (SELECT TOP 1 Growth FROM #TempDBFilesSingle WHERE FileName = @FileName)
			SET @FileType = (SELECT TOP 1 FileType FROM #TempDBFilesSingle WHERE FileName = @FileName)
			--PRINT @FileState

			IF @FileSize < 1.00	AND @Growth <> 100 AND @Status = 'ONLINE' AND @FileType <> 'FILESTREAM' AND @FileState = 'Online'
				BEGIN
					SET @sql = ' USE Master' + '
					ALTER DATABASE [' + @DBName + ']' + '
					MODIFY FILE ( NAME = N''' + @FileName + ''', FILEGROWTH = 100MB )'
					INSERT INTO #TempDBFilesAll (DBName, [FileName], OldGrowth, NewGrowth) VALUES (@DBName, @FileName, @Growth, '100')
				END
			ELSE IF @FileSize > 1.00 AND @FileSize < 10.00 	AND @Growth <> 500 AND @Status = 'ONLINE' AND @FileType <> 'FILESTREAM' AND @FileState = 'Online'
				BEGIN
					SET @sql = ' USE Master' + '
					ALTER DATABASE [' + @DBName + ']' + '
					MODIFY FILE ( NAME = N''' + @FileName + ''', FILEGROWTH = 500MB )'
					INSERT INTO #TempDBFilesAll (DBName, [FileName], OldGrowth, NewGrowth) VALUES (@DBName, @FileName, @Growth, '500')
				END
			ELSE IF @FileSize > 10.00 AND @Growth <> 1000 AND @Status = 'ONLINE' AND @FileType <> 'FILESTREAM' AND @FileState = 'Online'
				BEGIN
					SET @sql = ' USE Master' + '
					ALTER DATABASE [' + @DBName + ']' + '
					MODIFY FILE ( NAME = N''' + @FileName + ''', FILEGROWTH = 1000MB )'
					INSERT INTO #TempDBFilesAll (DBName, [FileName], OldGrowth, NewGrowth) VALUES (@DBName, @FileName, @Growth, '1000')
				END
			--PRINT @sql
			IF @sql <> ''
				EXEC sys.sp_executesql @sql

			DELETE FROM #TempDBFiles WHERE RowID = @RowID
			DELETE FROM #TempDBFilesSingle

		END
	IF (SELECT COUNT(DBName) FROM #TempDBFilesALL) > 0
		BEGIN
			--PRINT 'Email Sent'
			EXEC dbadmin.scs.scs_spQueryToHtmlTable @html = @html OUTPUT, @msg = 'File Growth Changed', @query = 'SELECT * FROM #TempDBFilesAll'
			EXEC msdb.dbo.sp_send_dbmail
				@profile_name = @profile,
				@recipients = 'dba@sixcolumnsolutions.com',
				@subject ='File Growth Change',
				@body = @html,
				@body_format = 'HTML',
				@query_no_truncate = 1,
				@attach_query_result_as_file = 0;
		END
	--ELSE
		--PRINT 'Email NOT Sent'

END











GO


