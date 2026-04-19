-- ============================================================
-- 01_SETBACKUPPATH.sql
-- Initializes backup configuration for all databases on a
-- new build and runs the first system database backup.
--
-- POWERSHELL TOKENS (replace before running):
--   {{BACKUP_ROOT}}      UNC or local path, e.g. D:\SQLBackups  or  \\nas01\sqlbak
--   {{CLEANUP_HOURS}}    Hours before backup files are purged, e.g. 168  (7 days)
-- ============================================================

-- Step 1: Seed the backup options table for all databases
EXEC dbadmin.maint.scs_updateSQLBackupOptions
    @Databases    = N'NEW_BUILD',
    @BackupType   = N'ALL',
    @Verify       = N'N',
    @CleanupTime  = {{CLEANUP_HOURS}},
    @BackupPath   = N'{{BACKUP_ROOT}}',
    @scs_Execute  = 'Y'

-- Step 2: Run the first full backup of system databases to confirm path works
EXEC dbadmin.bak.scs_RunBackups
    @Databases    = N'SYSTEM_DATABASES',
    @BackupType   = N'FULL',
    @Execute      = N'Y',
    @scs_SystemDBs = N'Y'
GO
