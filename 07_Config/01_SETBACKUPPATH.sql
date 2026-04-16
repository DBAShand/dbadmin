EXEC dbadmin.maint.scs_updateSQLBackupOptions @Databases = N'NEW_BUILD',                -- nvarchar(max)
                                               @BackupType = N'ALL',               -- nvarchar(max)
                                               @Verify = N'N',                   -- nvarchar(max)
                                               --@CleanupTime = 360,                -- int
                                               @scs_Execute = 'Y'               -- varchar(1)
											   
											   
											   
EXEC dbadmin.bak.scs_RunBackups @Databases = N'SYSTEM_DATABASES',                -- nvarchar(max)
                                 @BackupType = N'FULL',               -- nvarchar(max)
                                 @Execute = N'Y',                  -- nvarchar(max)
                                 @scs_SystemDBs = N'Y'            -- nvarchar(max)
