
USE DBAdmin
GO
Create VIEW maint.scs_vw_freespace_current
AS
SELECT dbname, db_files, file_loc, filesizeMB, spaceUsedMB, FreeSpaceMB, PercentSPaceFree,max(rundatetime) AS currentrundate from
dbadmin.maint.db_percentfree
GROUP BY dbname, db_files, file_loc, filesizeMB, spaceUsedMB, FreeSpaceMB, PercentSPaceFree
