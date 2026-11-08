USE [DBAdmin]
GO
/****** Object:  StoredProcedure [scs].[scs_CopyBackupHistory]    Script Date: 11/8/2026 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[scs].[scs_CopyBackupHistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [scs].[scs_CopyBackupHistory] AS'
END
GO

ALTER PROCEDURE [scs].[scs_CopyBackupHistory]
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	IF DB_NAME() <> N'DBAdmin'
	BEGIN
		RAISERROR('scs.scs_CopyBackupHistory must be executed in the DBAdmin database.', 16, 1);
		RETURN;
	END

	/*
		Copy the msdb backup history bak.sp_RestoreGene reads into DBAdmin.scs.
		Object names, columns, and keys match msdb.dbo.backupmediaset,
		msdb.dbo.backupset, and msdb.dbo.backupmediafamily.
		Identity values are preserved so media_set_id still joins.
		Rows already copied are left in place, including history that
		sp_delete_backuphistory has removed from msdb.
		Source rows are not deleted. SQL Server keeps writing backup history to msdb.
	*/

	IF OBJECT_ID(N'scs.backupmediaset', N'U') IS NULL
		OR OBJECT_ID(N'scs.backupset', N'U') IS NULL
		OR OBJECT_ID(N'scs.backupmediafamily', N'U') IS NULL
	BEGIN
		RAISERROR('DBAdmin.scs backup history tables are missing. Create scs.backupmediaset, scs.backupset, and scs.backupmediafamily first.', 16, 1);
		RETURN;
	END

	DECLARE @Copies TABLE
	(
		CopyOrder int NOT NULL PRIMARY KEY,
		SourceObject nvarchar(256) NOT NULL,
		DestObject nvarchar(256) NOT NULL,
		SourceTable sysname NOT NULL,
		HasIdentity bit NOT NULL,
		MatchPredicate nvarchar(400) NOT NULL
	);

	INSERT INTO @Copies (CopyOrder, SourceObject, DestObject, SourceTable, HasIdentity, MatchPredicate)
	VALUES
		(1, N'[msdb].[dbo].[backupmediaset]', N'[scs].[backupmediaset]', N'backupmediaset', 1, N'dst.[media_set_id] = src.[media_set_id]'),
		(2, N'[msdb].[dbo].[backupset]', N'[scs].[backupset]', N'backupset', 1, N'dst.[backup_set_id] = src.[backup_set_id]'),
		(3, N'[msdb].[dbo].[backupmediafamily]', N'[scs].[backupmediafamily]', N'backupmediafamily', 0, N'dst.[media_set_id] = src.[media_set_id] AND dst.[family_sequence_number] = src.[family_sequence_number] AND dst.[mirror] = src.[mirror]');

	DECLARE @CopyOrder int;
	DECLARE @SourceObject nvarchar(256);
	DECLARE @DestObject nvarchar(256);
	DECLARE @SourceTable sysname;
	DECLARE @HasIdentity bit;
	DECLARE @MatchPredicate nvarchar(400);
	DECLARE @ColumnList nvarchar(max);
	DECLARE @Sql nvarchar(max);
	DECLARE @RowCount int;

	BEGIN TRY
		BEGIN TRANSACTION;

		WHILE EXISTS (SELECT 1 FROM @Copies)
		BEGIN
			SELECT TOP (1)
				@CopyOrder = CopyOrder,
				@SourceObject = SourceObject,
				@DestObject = DestObject,
				@SourceTable = SourceTable,
				@HasIdentity = HasIdentity,
				@MatchPredicate = MatchPredicate
			FROM @Copies
			ORDER BY CopyOrder;

			SELECT @ColumnList = STUFF((
				SELECT N', ' + QUOTENAME(dest.name)
				FROM sys.columns AS dest
				INNER JOIN msdb.sys.columns AS src
					ON src.name = dest.name
				INNER JOIN msdb.sys.tables AS srcTable
					ON srcTable.object_id = src.object_id
				INNER JOIN msdb.sys.schemas AS srcSchema
					ON srcSchema.schema_id = srcTable.schema_id
				WHERE dest.object_id = OBJECT_ID(@DestObject)
					AND srcSchema.name = N'dbo'
					AND srcTable.name = @SourceTable
					AND dest.is_computed = 0
				ORDER BY dest.column_id
				FOR XML PATH(N''), TYPE).value(N'.[1]', N'nvarchar(max)'), 1, 2, N'');

			IF @ColumnList IS NULL OR LEN(@ColumnList) = 0
			BEGIN
				RAISERROR('No shared columns to copy into %s from msdb.dbo.%s.', 16, 1, @DestObject, @SourceTable);
			END

			SET @Sql = N'';

			IF @HasIdentity = 1
				SET @Sql = @Sql + N'SET IDENTITY_INSERT ' + @DestObject + N' ON; ';

			SET @Sql = @Sql + N'
INSERT INTO ' + @DestObject + N' (' + @ColumnList + N')
SELECT ' + @ColumnList + N'
FROM ' + @SourceObject + N' AS src
WHERE NOT EXISTS (
	SELECT 1
	FROM ' + @DestObject + N' AS dst
	WHERE ' + @MatchPredicate + N'
);
SET @RowCountOut = @@ROWCOUNT;';

			IF @HasIdentity = 1
				SET @Sql = @Sql + N' SET IDENTITY_INSERT ' + @DestObject + N' OFF;';

			EXEC sys.sp_executesql @Sql, N'@RowCountOut int OUTPUT', @RowCountOut = @RowCount OUTPUT;

			PRINT @DestObject + N' rows copied: ' + CAST(@RowCount AS varchar(20));

			DELETE FROM @Copies WHERE CopyOrder = @CopyOrder;
		END

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		BEGIN TRY
			SET IDENTITY_INSERT [scs].[backupmediaset] OFF;
		END TRY
		BEGIN CATCH
		END CATCH

		BEGIN TRY
			SET IDENTITY_INSERT [scs].[backupset] OFF;
		END TRY
		BEGIN CATCH
		END CATCH

		;THROW;
	END CATCH
END
GO
