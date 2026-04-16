USE [DBAdmin]
GO

/****** Object:  StoredProcedure [maint].[scs_updateSQLBackupOptions]    Script Date: 8/15/2018 3:03:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [maint].[scs_updateSQLBackupOptions]
		@Databases NVARCHAR(MAX),
		@Directory NVARCHAR(MAX) = NULL,
		@BackupType NVARCHAR(MAX),
		@Verify NVARCHAR(MAX) = 'N',
		@CleanupTime INT = NULL,
		@CleanupMode NVARCHAR(MAX) = 'AFTER_BACKUP',
		@Compress NVARCHAR(MAX) = NULL,
		@CopyOnly NVARCHAR(MAX) = 'N',
		@ChangeBackupType NVARCHAR(MAX) = 'N',
		@BackupSoftware NVARCHAR(MAX) = NULL,
		@CheckSum NVARCHAR(MAX) = 'N',
		@BlockSize INT = NULL,
		@BufferCount INT = NULL,
		@MaxTransferSize INT = NULL,
		@NumberOfFiles INT = NULL,
		@CompressionLevel INT = NULL,
		@Description NVARCHAR(MAX) = NULL,
		@Threads INT = NULL,
		@Throttle INT = NULL,
		@Encrypt NVARCHAR(MAX) = 'N',
		@EncryptionAlgorithm NVARCHAR(MAX) = NULL,
		@ServerCertificate NVARCHAR(MAX) = NULL,
		@ServerAsymmetricKey NVARCHAR(MAX) = NULL,
		@EncryptionKey NVARCHAR(MAX) = NULL,
		@ReadWriteFileGroups NVARCHAR(MAX) = 'N',
		@OverrideBackupPreference NVARCHAR(MAX) = 'N',
		@NoRecovery NVARCHAR(MAX) = 'N',
		@URL NVARCHAR(MAX) = NULL,
		@Credential NVARCHAR(MAX) = NULL,
		@MirrorDirectory NVARCHAR(MAX) = NULL,
		@MirrorCleanupTime INT = NULL,
		@MirrorCleanupMode NVARCHAR(MAX) = 'AFTER_BACKUP',
		@LogToTable NVARCHAR(MAX) = 'Y',
		@AvailabilityGroups NVARCHAR(MAX) = NULL,
		@Updateability NVARCHAR(MAX) = 'ALL',
		@AdaptiveCompression NVARCHAR(MAX) = NULL,
		@ModificationLevel INT = NULL,
		@LogSizeSinceLastLogBackup INT = NULL,
		@TimeSinceLastLogBackup INT = NULL,
		@DataDomainBoostHost NVARCHAR(MAX) = NULL,
		@DataDomainBoostUser NVARCHAR(MAX) = NULL,
		@DataDomainBoostDevicePath NVARCHAR(MAX) = NULL,
		@DataDomainBoostLockboxPath NVARCHAR(MAX) = NULL,
		@DirectoryStructure NVARCHAR(MAX) = '{DirectorySeparator}{DatabaseName}{DirectorySeparator}{BackupType}_{Partial}_{CopyOnly}',
		@AvailabilityGroupDirectoryStructure NVARCHAR(MAX) = '{DirectorySeparator}{DatabaseName}{DirectorySeparator}{BackupType}_{Partial}_{CopyOnly}',
		@FileName NVARCHAR(MAX) = '{ServerName}${InstanceName}_{DatabaseName}_{BackupType}_{Partial}_{CopyOnly}_{Year}{Month}{Day}_{Hour}{Minute}{Second}_{FileNumber}.{FileExtension}',
		@AvailabilityGroupFileName NVARCHAR(MAX) = '{ClusterName}${AvailabilityGroupName}_{DatabaseName}_{BackupType}_{Partial}_{CopyOnly}_{Year}{Month}{Day}_{Hour}{Minute}{Second}_{FileNumber}.{FileExtension}',
		@FileExtensionFull NVARCHAR(MAX) = 'bak',
		@FileExtensionDiff NVARCHAR(MAX) = 'dif',
		@FileExtensionLog NVARCHAR(MAX) = 'trn',
		@Execute NVARCHAR(MAX) = 'Y',
		@scs_Execute VARCHAR(1) = NULL
		
AS
	SET NOCOUNT ON;
BEGIN
IF @scs_Execute IS NULL 
	BEGIN
	SET @scs_Execute = 'N'
	END
IF @scs_Execute = 'N'
   BEGIN
   PRINT 'Execution is Suppressed, Update will not occur'
   END

   /* declaring variables that can be used to run the stored procedure */
DECLARE @RunDatabases NVARCHAR(MAX)
DECLARE @RunDirectory NVARCHAR(MAX) = NULL
DECLARE @RunBackupType NVARCHAR(MAX)
DECLARE @RunVerify NVARCHAR(MAX) = 'N'
DECLARE @RunCleanupTime INT = 504
DECLARE @RunCleanupMode NVARCHAR(MAX) = 'AFTER_BACKUP'
DECLARE @RunCompress NVARCHAR(MAX) = 'Y'
DECLARE @RunCopyOnly NVARCHAR(MAX) = 'N'
DECLARE @RunChangeBackupType NVARCHAR(MAX) = 'N'
DECLARE @RunBackupSoftware NVARCHAR(MAX) = NULL
DECLARE @RunCheckSum NVARCHAR(MAX) = 'N'
DECLARE @RunBlockSize INT = NULL
DECLARE @RunBufferCount INT = NULL
DECLARE @RunMaxTransferSize INT = NULL
DECLARE @RunNumberOfFiles INT = NULL
DECLARE @RunCompressionLevel INT = NULL
DECLARE @RunDescription NVARCHAR(MAX) = NULL
DECLARE @RunThreads INT = NULL
DECLARE @RunThrottle INT = NULL
DECLARE @RunEncrypt NVARCHAR(MAX) = 'N'
DECLARE @RunEncryptionAlgorithm NVARCHAR(MAX) = NULL
DECLARE @RunServerCertificate NVARCHAR(MAX) = NULL
DECLARE @RunServerAsymmetricKey NVARCHAR(MAX) = NULL
DECLARE @RunEncryptionKey NVARCHAR(MAX) = NULL
DECLARE @RunReadWriteFileGroups NVARCHAR(MAX) = 'N'
DECLARE @RunOverrideBackupPreference NVARCHAR(MAX) = 'N'
DECLARE @RunNoRecovery NVARCHAR(MAX) = 'N'
DECLARE @RunURL NVARCHAR(MAX) = NULL
DECLARE @RunCredential NVARCHAR(MAX) = NULL
DECLARE @RunMirrorDirectory NVARCHAR(MAX) = NULL
DECLARE @RunMirrorCleanupTime INT = NULL
DECLARE @RunMirrorCleanupMode NVARCHAR(MAX) = 'AFTER_BACKUP'
DECLARE @RunLogToTable NVARCHAR(MAX) = 'N'

DECLARE @RunAvailabilityGroups nvarchar(max) = NULL
DECLARE @RunUpdateability nvarchar(max) = 'ALL'
DECLARE @RunAdaptiveCompression nvarchar(max) = NULL
DECLARE @RunModificationLevel int = NULL
DECLARE @RunLogSizeSinceLastLogBackup int = NULL
DECLARE @RunTimeSinceLastLogBackup int = NULL
DECLARE @RunDataDomainBoostHost nvarchar(max) = NULL
DECLARE @RunDataDomainBoostUser nvarchar(max) = NULL
DECLARE @RunDataDomainBoostDevicePath nvarchar(max) = NULL
DECLARE @RunDataDomainBoostLockboxPath nvarchar(max) = NULL
DECLARE @RunDirectoryStructure nvarchar(max) = '{DirectorySeparator}{DatabaseName}{DirectorySeparator}{BackupType}_{Partial}_{CopyOnly}'
DECLARE @RunAvailabilityGroupDirectoryStructure nvarchar(max) = '{DirectorySeparator}{DatabaseName}{DirectorySeparator}{BackupType}_{Partial}_{CopyOnly}'
DECLARE @RunFileName nvarchar(max) = '{ServerName}${InstanceName}_{DatabaseName}_{BackupType}_{Partial}_{CopyOnly}_{Year}{Month}{Day}_{Hour}{Minute}{Second}_{FileNumber}.{FileExtension}'
DECLARE @RunAvailabilityGroupFileName nvarchar(max) = '{ClusterName}${AvailabilityGroupName}_{DatabaseName}_{BackupType}_{Partial}_{CopyOnly}_{Year}{Month}{Day}_{Hour}{Minute}{Second}_{FileNumber}.{FileExtension}'
DECLARE @RunFileExtensionFull nvarchar(max) = 'bak'
DECLARE @RunFileExtensionDiff nvarchar(max) = 'dif'
DECLARE @RunFileExtensionLog nvarchar(max) = 'trn'

DECLARE @RunExecute NVARCHAR(MAX) = 'Y'
DECLARE @Error			INT = 0
DECLARE @ErrorMessage	NVARCHAR(MAX)
DECLARE @sql2 NVARCHAR(MAX)
DECLARE @CheckDatabases NVARCHAR(MAX)

DECLARE @backupfolder				varchar(50)
DECLARE @backuppath					nvarchar(300)
DECLARE @hostname					VARCHAR(30)
DECLARE @environmentshort			char(1)
DECLARE @backuppathfirst			varchar(11) = '\\scs\BU\'
DECLARE @BACKUPPATHsecond			varchar(8)  = 'DCDB\MS\'
DECLARE @MirrorPathSecond	        varchar(12) = 'DCDB_KDC\MS\'
DECLARE @datacenter					nvarchar(300)
DECLARE @envrionment				nvarchar(300)
DECLARE @sql3						nvarchar(max)


DECLARE @databaseloopcnt INT 
DECLARE @maxdatabaseloop INT


DECLARE @typeloop TABLE
	   (
          id INT  NOT null
         ,type NVARCHAR(MAX) NOT null
	   )

DECLARE @databaseloop TABLE
	   (
          id INT IDENTITY(1,1) NOT NULL
         ,[databases] NVARCHAR(MAX) NOT null
	   )


/*This code is for a new build of a server. Removed the configure backup parms
	Pass the "Database name 'NEW_BUILD' when calling the proc.
*/
SET @RunBackupType = @BackupType
IF @Databases = 'NEW_BUILD'
	BEGIN
		TRUNCATE TABLE DBAdmin.bak.scs_SQLBackupOptions
		SET @RunBackupType = 'ALL'
		  INSERT @databaseloop SELECT name FROM master.sys.databases
	END
	ELSE
		   BEGIN
		   INSERT INTO @databaseloop VALUES (@Databases)
		   END
		
	--IF @Directory				 IS NOT NULL SET @RunDirectory					= @Directory

		
		--SELECT * FROM DBAdmin.bak.scs_SQLBackupOptions
		
   --END
/*Forces check and raises error for BackupType and Database*/  
IF @Databases is null
	BEGIN
		SET @ErrorMessage = 'Please Enter a Database: ' +  ISNULL(@Databases,'NULL')
		RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
		SET @Error = @@ERROR
	END

IF @BackupType is null
	BEGIN
		SET @ErrorMessage = 'Please Enter a Backup Type: ' +  ISNULL(@BackupType,'NULL')
		RAISERROR(@ErrorMessage,16,1) WITH NOWAIT
		SET @Error = @@ERROR
	END
SET @Directory = (SELECT REPLACE (@Directory,@Databases,''))
--SET @directory = (SELECT replace (LEFT(@Directory,2),'\\','\'))
  IF @ERROR = 0 
  BEGIN
   DECLARE @loopmax INT
   DECLARE @loop INT

  
  IF (@RunBackupType = 'ALL')
  BEGIN
		SET @loopmax = 3
		INSERT INTO @typeloop VALUES (1,'Full')
		INSERT INTO @typeloop VALUES (2,'Diff')
		INSERT INTO @typeloop VALUES (3,'Log')
   END
   ELSE 
   BEGIN
		SET @loopmax = 1
		INSERT INTO @typeloop VALUES (1,@RunBackupType)
		
		--INSERT INTO @databaseloop VALUES (@Databases)
	END


  IF @ERROR = 0 
  BEGIN
  SET @databaseloopcnt = 1
  SELECT @maxdatabaseloop = MAX(id) FROM @databaseloop 
  --SELECT * FROM @databaseloop
  WHILE @databaseloopcnt <= @maxdatabaseloop
        BEGIN
		PRINT @databaseloopcnt
        SELECT @RunDatabases = databases
		FROM @databaseloop WHERE id = @databaseloopcnt
   SET @loop = 1
   WHILE @loop <= @loopmax
        BEGIN
               IF @loopmax > 1
				Begin
  					SELECT 
					 @RunBackupType = type
					 FROM @typeloop
					 WHERE id = @loop
				 END

  SET @RunCleanupTime = 504
  SET @RunMirrorCleanupTime = NULL
  IF EXISTS (SELECT * FROM bak.scs_SQLBackupOptions BU WHERE BU.Databases = @RunDatabases AND BU.BackupType = @RunBackupType
			AND BU.stoptimestamp = '1753-01-01 00:00:00.000')
   BEGIN
	
	   SELECT 
		       @RunDirectory							= BU.Directory
              ,@RunBackupType							= BU.BackupType
		      ,@RunVerify								= BU.Verify 
		      ,@RunCleanupTime							= BU.CleanupTime
		      ,@RunCleanupMode							= BU.CleanupMode
		      ,@RunCompress								= BU.Compress
		      ,@RunCopyOnly								= BU.CopyOnly
		      ,@RunChangeBackupType						= BU.ChangeBackupType
		      ,@RunBackupSoftware						= BU.BackupSoftware
		      ,@RunCheckSum								= BU.CheckSum
		      ,@RunBlockSize							= BU.BlockSize
		      ,@RunBufferCount							= BU.BufferCount
		      ,@RunMaxTransferSize						= BU.MaxTransferSize
		      ,@RunNumberOfFiles						= BU.NumberOfFiles
		      ,@RunCompressionLevel						= BU.CompressionLevel
		      ,@RunDescription							= BU.Description
		      ,@RunThreads								= BU.Threads
		      ,@RunThrottle								= BU.Throttle
		      ,@RunEncrypt								= BU.Encrypt
		      ,@RunEncryptionAlgorithm					= BU.EncryptionAlgorithm
		      ,@RunServerCertificate					= BU.ServerCertificate
		      ,@RunServerAsymmetricKey					= BU.ServerAsymmetricKey
		      ,@RunEncryptionKey						= BU.EncryptionKey
		      ,@RunReadWriteFileGroups					= BU.ReadWriteFileGroups
		      ,@RunOverrideBackupPreference				= BU.OverrideBackupPreference
		      ,@RunNoRecovery							= BU.NoRecovery
		      ,@RunURL									= BU.URL
		      ,@RunCredential							= BU.Credential
		      ,@RunMirrorDirectory						= BU.MirrorDirectory
		      ,@RunMirrorCleanupTime					= BU.MirrorCleanupTime
		      ,@RunMirrorCleanupMode					= BU.MirrorCleanupMode
			  ,@RunAvailabilityGroups					= BU.AvailabilityGroups
			  ,@RunUpdateability						= BU.Updateability
			  ,@RunAdaptiveCompression					= BU.Adaptivecompression
			  ,@RunModificationLevel					= BU.ModificationLevel	
			  ,@RunLogSizeSinceLastLogBackup			= BU.LogSizeSinceLastLogBackup
			  ,@RunTimeSinceLastLogBackup				= BU.TimeSinceLastLogBackup	
			  ,@RunDataDomainBoostHost					= BU.DataDomainBoostHost
			  ,@RunDataDomainBoostUser					= BU.DataDomainBoostUser
			  ,@RunDataDomainBoostDevicePath			= BU.DataDomainBoostDevicePath
			  ,@RunDataDomainBoostLockboxPath			= BU.DataDomainBoostLockboxPath
			  ,@RunDirectoryStructure					= BU.DirectoryStructure
			  ,@RunAvailabilityGroupDirectoryStructure  = BU.AvailabilityGroupDirectoryStructure 
			  ,@RunFileName								= BU.FileName
			  ,@RunAvailabilityGroupFileName			= BU.AvailabilityGroupFileName 
			  ,@RunFileExtensionFull					= BU.FileExtensionFull
			  ,@RunFileExtensionDiff					= BU.FileExtensionDiff
			  ,@RunFileExtensionLog						= BU.FileExtensionLog
		      ,@RunLogToTable							= BU.LogToTable
		      ,@RunExecute								= BU.[Execute]
	FROM bak.scs_SQLBackupOptions BU WHERE BU.Databases = @RunDatabases AND BU.BackupType = @RunBackupType
	AND BU.stoptimestamp = '1753-01-01 00:00:00.000'

END
/*
This sets the default backup path as we expect it to be.  If we decide to change or update it, we will have to do so later.  
This works only for the new naming convetions.  Adding 2014 legacy naming conventions, will have to be completed by plugging in the variable.  
*/
IF @Directory IS NULL
BEGIN

		
		SET @datacenter = (select substring(@@servername,2,1))
		--PRINT @datacenter 
		set @backupfolder = REPLACE(@@SERVERNAME,'\','$')
		--PRINT @backupfolder
		--SELECT @@SERVERNAME
		SET @environmentshort = (SELECT SUBSTRING(@@SERVERNAME,1,1))
		
		PRINT 'envrioment short ' + @environmentshort
		--SET @hostname = (select left(@@servername,(CHARINDEX('\',@@SERVERNAME)-1)))
		SET @hostname = (SELECT @@servername)
		--PRINT @hostname
		
		--SET @environmentshort  = 'P'
		IF @environmentshort = 'D'
		       SET @envrionment = 'DEV'
		ELSE IF @environmentshort = 'U'
		       SET @envrionment = 'UAT' 
		ELSE IF @environmentshort = 'I'
		       SET @envrionment = 'INT' 
		ELSE IF @environmentshort = 'P'
		       SET @envrionment = 'PRD' 
		ELSE IF @environmentshort = 'T'
		       SET @envrionment = 'DEV'
		PRINT 'environment ' + @environmentshort
		
		SET @RunDirectory = @backuppathfirst + @datacenter + @BACKUPPATHsecond +  @envrionment + '\' + @hostname
		IF @datacenter = 'O'
		BEGIN
		SET @RunMirrorDirectory = @backuppathfirst + @datacenter + @MirrorPathSecond + @envrionment + '\' + @hostname
		END
		PRINT @RunDirectory
		
END
ELSE	
BEGIN 
SET @RunDirectory = @Directory --+ '\' + @RunDatabases

END
--IF  @RunDirectory =  (@backuppathfirst + @datacenter + @BACKUPPATHsecond +  @envrionment + '\' + @hostname)
--    BEGIN
--	   IF @Directory				 IS NOT NULL SET @RunDirectory					= @Directory
--	   	   SET @CheckDatabases = '''%' + @RunDatabases + '%'''
--	   PRINT @Checkdatabases 
--	   IF @RunDirectory  LIKE '''%' + @RunDatabases + '%'''
--	      BEGIN
--				SET @RunDirectory = @Directory + '\' + @RunDatabases
--		  END
--	   ELSE 
--	   BEGIN
--	   SET @RunDirectory = @RunDirectory + '\' + @RunDatabases
--	   END
--    END
		         
			If @envrionment = 'PRD'
                              BEGIN
			 IF @RunBackupType = 'Diff'
					BEGIN
						SET @RunCleanupTime = 48
						SET @RunMirrorCleanupTime = 48
				END 
 						SET @RunCleanupTime = Null
						SET @RunMirrorCleanupTime = Null

				END         
		IF @BackupType <> 'ALL'
		   BEGIN

				IF @BackupType				 IS NOT NULL SET @RunBackupType					= @BackupType
		   END
		IF @Verify								IS NOT NULL SET @RunVerify									= @Verify					
		IF @CleanupTime							IS NOT NULL SET @RunCleanupTime								= @CleanupTime
		IF @CleanupMode							IS NOT NULL SET @RunCleanupMode								= @CleanupMode
		IF @Compress							IS NOT NULL SET @RunCompress								= @Compress
		IF @CopyOnly							IS NOT NULL SET @RunCopyOnly								= @CopyOnly
		IF @ChangeBackupType					IS NOT NULL SET @RunChangeBackupType						= @ChangeBackupType
		IF @BackupSoftware						IS NOT NULL SET @RunBackupSoftware							= @BackupSoftware
		IF @CheckSum							IS NOT NULL SET @RunCheckSum								= @CheckSum
		IF @BlockSize							IS NOT NULL SET @RunBlockSize								= @BlockSize
		IF @BufferCount							IS NOT NULL SET @RunBufferCount								= @BufferCount
		IF @MaxTransferSize						IS NOT NULL SET @RunMaxTransferSize							= @MaxTransferSize
		IF @NumberOfFiles						IS NOT NULL SET @RunNumberOfFiles							= @NumberOfFiles
		IF @CompressionLevel					IS NOT NULL SET @RunCompressionLevel						= @CompressionLevel
		IF @Description							IS NOT NULL SET @RunDescription								= @Description
		IF @Threads								IS NOT NULL SET @RunThreads									= @Threads
		IF @Throttle							IS NOT NULL SET @RunThrottle								= @Throttle
		IF @Encrypt								IS NOT NULL SET @RunEncrypt									= @Encrypt
		IF @EncryptionAlgorithm					IS NOT NULL SET @RunEncryptionAlgorithm    					= @EncryptionAlgorithm
		IF @ServerCertificate					IS NOT NULL SET @RunServerCertificate						= @ServerCertificate
		IF @ServerAsymmetricKey					IS NOT NULL SET @RunServerAsymmetricKey						= @ServerAsymmetricKey
		IF @EncryptionKey						IS NOT NULL SET @RunEncryptionKey							= @EncryptionKey
		IF @ReadWriteFileGroups					IS NOT NULL SET @RunReadWriteFileGroups						= @ReadWriteFileGroups
		IF @OverrideBackupPreference			IS NOT NULL SET @RunOverrideBackupPreference				= @OverrideBackupPreference
		IF @NoRecovery							IS NOT NULL SET @RunNoRecovery								= @NoRecovery
		IF @URL									IS NOT NULL SET @RunURL										= @URL
		IF @Credential							IS NOT NULL SET @RunCredential								= @Credential
		IF @MirrorDirectory						IS NOT NULL SET @RunMirrorDirectory							= @MirrorDirectory
		IF @MirrorCleanupTime					IS NOT NULL SET @RunMirrorCleanupTime						= @MirrorCleanupTime
		IF @MirrorCleanupMode					IS NOT NULL SET @RunMirrorCleanupMode						= @MirrorCleanupMode
		IF @AvailabilityGroups					IS NOT NULL SET @RunAvailabilityGroups						= @AvailabilityGroups  
		IF @Updateability						IS NOT NULL SET @RunUpdateability							= @Updateability
		IF @AdaptiveCompression					IS NOT NULL SET @RunAdaptiveCompression						= @AdaptiveCompression
		IF @ModificationLevel					IS NOT NULL SET @RunModificationLevel						= @ModificationLevel
		IF @LogSizeSinceLastLogBackup			IS NOT NULL SET @RunLogSizeSinceLastLogBackup				= @LogSizeSinceLastLogBackup
		IF @TimeSinceLastLogBackup				IS NOT NULL SET @RunTimeSinceLastLogBackup					= @TimeSinceLastLogBackup
		IF @DataDomainBoostHost					IS NOT NULL SET @RunDataDomainBoostHost						= @DataDomainBoostHost
		IF @DataDomainBoostUser					IS NOT NULL SET @RunDataDomainBoostUser						= @DataDomainBoostUser	
		IF @DataDomainBoostDevicePath			IS NOT NULL SET @RunDataDomainBoostDevicePath				= @DataDomainBoostDevicePath
		IF @DataDomainBoostLockboxPath			IS NOT NULL SET @RunDataDomainBoostLockboxPath				= @DataDomainBoostLockboxPath
		IF @DirectoryStructure					IS NOT NULL SET @RunDirectoryStructure						= @DirectoryStructure
		IF @AvailabilityGroupDirectoryStructure IS NOT NULL SET @RunAvailabilityGroupDirectoryStructure		= @AvailabilityGroupDirectoryStructure
		IF @FileName							IS NOT NULL SET @RunFileName								= @FileName
		IF @AvailabilityGroupFileName			IS NOT NULL SET @RunAvailabilityGroupFileName				= @AvailabilityGroupFileName
		IF @FileExtensionFull					IS NOT NULL SET @RunFileExtensionFull						= @FileExtensionFull
		IF @FileExtensionDiff					IS NOT NULL SET @RunFileExtensionDiff						= @FileExtensionDiff
		IF @FileExtensionLog					IS NOT NULL SET @RunFileExtensionLog						= @FileExtensionLog
		IF @LogToTable							IS NOT NULL SET @RunLogToTable								= @LogToTable
		IF @Execute								IS NOT NULL SET @RunExecute									= @Execute
	--END


SET @sql2 =  '--DO NOT RUN THIS STATEMENT!!! If you need to run this replace ''NULL'' with NULL
IF EXISTS (SELECT A.Databases FROM bak.scs_SQLBackupOptions A WHERE A.Databases = ''' + @RunDatabases + ''' AND stoptimestamp = ''1753-01-01 00:00:00.000'' and BackupType = ''' + @RunBackupType + ''') UPDATE bak.scs_SQLBackupOptions SET stoptimestamp = GETDATE() WHERE [Databases] = ''' + @Databases + ''' AND [BackupType] = ' + '' + @RunBackupType + '''
insert into bak.scs_SQLBackupOptions
            (
			 Databases
			,Directory
			,BackupType				
			,Verify					
			,CleanupTime				
			,CleanupMode				
			,Compress					
			,CopyOnly					
			,ChangeBackupType			
			,BackupSoftware			
			,CheckSum					
			,BlockSize				
			,BufferCount				
			,MaxTransferSize			
			,NumberOfFiles			
			,CompressionLevel			
			,Description				
			,Threads					
			,Throttle					
			,Encrypt					
			,EncryptionAlgorithm		
			,ServerCertificate		
			,ServerAsymmetricKey		
			,EncryptionKey			
			,ReadWriteFileGroups		
			,OverrideBackupPreference	
			,NoRecovery				
			,URL						
			,Credential				
			,MirrorDirectory			
			,MirrorCleanupTime		
			,MirrorCleanupMode	
			,AvailabilityGroups
			,Updateability
			,AdaptiveCompression
			,ModificationLeve
			,LogSizeSinceLastLogBackup
			,TimeSinceLastLogBackup
			,DataDomainBoostHost
			,DataDomainBoostUser
			,DataDomainBoostDevicePath
			,DataDomainBoostLockboxPath
			,DirectoryStructure
			,AvailabilityGroupDirectoryStructure
			,FileName
			,AvailabilityGroupFileName
			,FileExtensionFull
			,FileExtensionDiff
			,FileExtensionLog
			,LogToTable				
			,[Execute]					

			)
			values
			(
				     ''' +  ISNULL(@RunDatabases,'Null') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunDirectory,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunBackupType,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunVerify,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(CONVERT(VARCHAR(MAX),@RunCleanupTime),'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunCleanupMode,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunCompress,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunCopyOnly,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunChangeBackupType,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunBackupSoftware,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunCheckSum,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(CONVERT(VARCHAR(MAX),@RunBlockSize),'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(CONVERT(VARCHAR(MAX),@RunBuffercount),'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(CONVERT(VARCHAR(MAX),@RunMaxTransferSize),'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(CONVERT(VARCHAR(MAX),@RunNumberOfFiles),'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(CONVERT(VARCHAR(4),@RunCompressionLevel),'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunDescription,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(CONVERT(VARCHAR(MAX),@RunThreads),'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(CONVERT(VARCHAR(MAX),@RunThrottle),'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunEncrypt,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunEncryptionAlgorithm,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunServerCertificate,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunServerAsymmetricKey,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunEncryptionKey,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunReadWriteFileGroups,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunOverrideBackupPreference,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunNoRecovery,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunURL,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunCredential,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunMirrorDirectory,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(CONVERT(VARCHAR(MAX),@RunMirrorCleanupTime),'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunMirrorCleanupMode,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunAvailabilityGroups,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunUpdateability,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunAdaptiveCompression,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(CONVERT(varchar(MAX),@RunModificationLevel),'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(CONVERT(varchar(MAX),@RunLogSizeSinceLastLogBackup),'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(CONVERT(varchar(MAX),@RunTimeSinceLastLogBackup),'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunDataDomainBoostHost,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunDataDomainBoostUser,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunDataDomainBoostDevicePath,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunDataDomainBoostLockboxPath,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunDirectoryStructure,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunAvailabilityGroupDirectoryStructure,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunFileName,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunAvailabilityGroupFileName,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunFileExtensionFull,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunFileExtensionDiff,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunFileExtensionLog,'NULL') 
				+ '''' + char(13) + char(10) + ', '''   +  ISNULL(@RunLogToTable,'NULL') 
				+ '''' + char(13) + char(10) + ', '''  +  ISNULL(@RunExecute,'NULL') 
				+ '''' + char(13) + char(10) + ')'

--				PRINT @sql2
	IF @scs_Execute = 'Y' 
	   BEGIN

	  IF EXISTS (SELECT A.Databases FROM bak.scs_SQLBackupOptions A WHERE A.Databases = @RunDatabases AND A.stoptimestamp = '1753-01-01 00:00:00.000' and BackupType = @RunBackupType) UPDATE bak.scs_SQLBackupOptions SET stoptimestamp = GETDATE() WHERE [Databases] = @RunDatabases AND [BackupType] = @RunBackUpType
	  INSERT INTO bak.scs_SQLBackupOptions
            (
			 Databases
			,Directory
			,BackupType				
			,Verify					
			,CleanupTime				
			,CleanupMode				
			,Compress					
			,CopyOnly					
			,ChangeBackupType			
			,BackupSoftware			
			,CheckSum					
			,BlockSize				
			,BufferCount				
			,MaxTransferSize			
			,NumberOfFiles			
			,CompressionLevel			
			,Description				
			,Threads					
			,Throttle					
			,Encrypt					
			,EncryptionAlgorithm		
			,ServerCertificate		
			,ServerAsymmetricKey		
			,EncryptionKey			
			,ReadWriteFileGroups		
			,OverrideBackupPreference	
			,NoRecovery				
			,URL						
			,Credential				
			,MirrorDirectory			
			,MirrorCleanupTime		
			,MirrorCleanupMode	
			,AvailabilityGroups
			,Updateability
			,AdaptiveCompression
			,ModificationLevel
			,LogSizeSinceLastLogBackup
			,TimeSinceLastLogBackup
			,DataDomainBoostHost
			,DataDomainBoostUser
			,DataDomainBoostDevicePath
			,DataDomainBoostLockboxPath
			,DirectoryStructure
			,AvailabilityGroupDirectoryStructure
			,FileName
			,AvailabilityGroupFileName
			,FileExtensionFull
			,FileExtensionDiff
			,FileExtensionLog
				
			,LogToTable				
			,[Execute]					

			)
			VALUES
			(
			 @RunDatabases
			,@RunDirectory					
			,@RunBackupType					
			,@RunVerify						
			,@RunCleanupTime				
			,@RunCleanupMode				
			,@RunCompress					
			,@RunCopyOnly					
			,@RunChangeBackupType			
			,@RunBackupSoftware				
			,@RunCheckSum					
			,@RunBlockSize					
			,@RunBufferCount				
			,@RunMaxTransferSize			
			,@RunBackupSoftware				
			,@RunCompressionLevel			
			,@RunDescription				
			,@RunThreads					
			,@RunThrottle					
			,@RunEncrypt					
			,@RunEncryptionAlgorithm    	
			,@RunServerCertificate			
			,@RunServerAsymmetricKey		
			,@RunEncryptionKey				
			,@RunReadWriteFileGroups		
			,@RunOverrideBackupPreference	
			,@RunNoRecovery					
			,@RunURL						
			,@RunCredential					
			,@RunMirrorDirectory			
			,@RunMirrorCleanupTime			
			,@RunMirrorCleanupMode
			,@RunAvailabilityGroups
			,@RunUpdateability
			,@RunAdaptiveCompression
			,@RunModificationLevel
			,@RunLogSizeSinceLastLogBackup
			,@RunTimeSinceLastLogBackup
			,@RunDataDomainBoostHost
			,@RunDataDomainBoostUser
			,@RunDataDomainBoostDevicePath
			,@RunDataDomainBoostLockboxPath
			,@RunDirectoryStructure
			,@RunAvailabilityGroupDirectoryStructure
			,@RunFileName
			,@RunAvailabilityGroupFileName
			,@RunFileExtensionFull
			,@RunFileExtensionDiff
			,@RunFileExtensionLog			
			,@RunLogToTable					
			,@RunExecute		
			)		
			
	
	SET @sql3 = 'EXEC master.dbo.xp_create_subdir ' + '''' + @RunDirectory + ''''
	EXEC (@sql3)
   PRINT @sql3
	SET @sql3 = 'EXEC master.dbo.xp_create_subdir ' + '''' + @RunMirrorDirectory + ''''
	EXEC (@sql3)
   PRINT @sql3
END
   SET @loop = @loop + 1	 
END

SET @databaseloopcnt = @databaseloopcnt + 1
END
END
END
END

UPDATE [DBAdmin].[bak].[scs_SQLBackupOptions] SET CleanupTime = 48
WHERE BackupType = 'DIFF'











GO


