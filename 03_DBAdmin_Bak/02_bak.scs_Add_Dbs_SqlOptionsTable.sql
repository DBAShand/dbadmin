EXEC DBAdmin.maint.scs_updateSQLBackupOptions @Databases = N'New_Build', -- nvarchar(max)

    @BackupType = N'ALL', -- nvarchar(max)

    @scs_Execute = 'Y' -- varchar(1)
	