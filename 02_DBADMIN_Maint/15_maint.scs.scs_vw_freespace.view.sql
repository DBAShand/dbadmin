
USE DBAdmin
GO
Create VIEW maint.scs_vw_freespace
AS
SELECT dbname, db_files, file_loc, filesizeMB, spaceUsedMB, FreeSpaceMB, PercentSPaceFree,rundatetime AS currentrundate from
dbadmin.maint.db_percentfree
GROUP BY rundatetime, dbname, db_files, file_loc, filesizeMB, spaceUsedMB, FreeSpaceMB, PercentSPaceFree
