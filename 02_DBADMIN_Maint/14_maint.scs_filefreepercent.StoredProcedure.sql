USE DBAdmin
GO

CREATE PROCEDURE maint.scs_filefreepercent
	 @database_names NVARCHAR(MAX) =  NULL,
	 @scs_EXECUTE CHAR(1) = 'N'
AS
BEGIN
DECLARE @database_namesRun NVARCHAR(MAX)
SET @database_namesRun = @database_names
 
SET NOCOUNT ON

IF OBJECT_ID('tempdb..#TempList') IS NOT NULL
    DROP TABLE #TempList
	CREATE TABLE #TempList
	(
		tbldbName sysname NULL
	)



IF @database_namesRun IS NOT NULL
BEGIN
	DECLARE @tmpDBName varchar(max)
	DECLARE @Pos int

	SET @database_namesRun = LTRIM(RTRIM(@database_namesRun))+ ','
	SET @Pos = CHARINDEX(',', @database_namesRun, 1)

	IF REPLACE(@database_namesRun, ',', '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @tmpDBName = LTRIM(RTRIM(LEFT(@database_namesRun, @Pos - 1)))
			IF @tmpDBName <> ''
			BEGIN
				INSERT INTO #TempList (tbldbName) VALUES (CAST(@tmpDBName AS SYSNAME)) --Use Appropriate conversion
			END
			SET @database_namesRun = RIGHT(@database_namesRun, LEN(@database_namesRun) - @Pos)
			SET @Pos = CHARINDEX(',', @database_namesRun, 1)

		END
	END		
END
ELSE 
BEGIN
INSERT INTO #TempList SELECT DISTINCT(name) from dbadmin.scs.scs_vw_User_DBs
END

SELECT * FROM #TempList

DECLARE @databases TABLE
       (
              rowID INT IDENTITY(1,1)
              ,command NVARCHAR(MAX)
       )



       INSERT INTO @databases
       SELECT  'use [' + tbldbName + ']
	   INSERT INTO dbadmin.maint.db_percentfree
	   select
	   ''' + tbldbName + '''
	   ,name
	   ,filename
	   ,convert(decimal(12,2),round(a.size/128.000,2) as FileSizeMB
	   ,convert(decimal(12,2),round(fileproperty(a.name,''SpaceUsed'')/128.000,2) as SpaceUsedMB
	   ,convert(decimal(12,2),round((a.size-fileproperty(a.name,''SpaceUsed''))/128.000,2) as FreeSpaceMB
	   ,convert(decimal(12,2),(convert(decimal(12,2),round((size-fileproperty(a.name,''SpaceUsed''))/128.000,2)))/convert(decimal(12,2),round(size/128.000,2))) * 100 AS SPACE_FREE_PERCENT
	   ,getdate()
	   from dbo.sysfiles a'
    FROM #TempList


       DECLARE @databasesCounter INT
       DECLARE @maxRowID_LSJobs INT
       DECLARE @Command NVARCHAR(MAX)
	   SET @Command = ''
       SELECT @maxRowID_LSJobs = MAX(rowID) 
       FROM @databases

       SET @databasesCounter = 1

       WHILE @databasesCounter <= @maxRowID_LSJobs
              BEGIN
                     Select @command = @command + ' ' + command
                     FROM @databases
                     WHERE rowID = @databasesCounter
				                     SET @databasesCounter = @databasesCounter + 1

              END
SELECT * FROM @databases
IF @scs_EXECUTE = 'Y'
					 Begin
                     EXECUTE sp_executesql @Command
					 END
                     PRINT @Command

END


