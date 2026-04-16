/*sets Server properities for new builds*/

/*DECLARE VARIABLES TO BE USED */
DECLARE @physicalmemory AS BIGINT 		-- PHYSICAL MEMORY OF SQL HOST
DECLARE @sqlservermaxmemory AS BIGINT	-- NEW MAX MEMORY FOR INSTANCE
DECLARE @sqlserverminmemory AS BIGINT 	-- NEW MIN MEMORY FOR INSTANCE

/*IF WE HAVE MULTIPLE INSTANCES CHANGE THE VALUE TO PRE-DEFINED VALUE*/
SET @sqlserverminmemory = 0		-- THIS IS MB AND MUST BE GREAT THAN 10240 FOR A VALID VALUE
SET @sqlservermaxmemory = 0		-- THIS IS MB AND MUST BE GREAT THAN 102400 FOR A VALID VALUE
SELECT @physicalmemory = total_physical_memory_kb 
FROM sys.dm_os_sys_Memory

IF @sqlservermaxmemory < 10240 --SET TO 10240 BECAUSE SQL SERVER WILL HAVE A MINIM OF 128 MB
BEGIN
  	IF @physicalmemory <  41943040
SET @sqlservermaxmemory =  @physicalmemory - 4194304
ELSE
SET @sqlservermaxmemory =  @physicalmemory * .90
END



SET @sqlservermaxmemory = @sqlservermaxmemory / 1024
SET @sqlserverminmemory = @sqlserverminmemory / 1024
PRINT @sqlserverminmemory
PRINT @sqlservermaxmemory
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
EXEC sys.sp_configure N'max server memory (MB)', @sqlservermaxmemory RECONFIGURE WITH OVERRIDE
EXEC sys.sp_configure N'min server memory (MB)', @sqlserverminmemory RECONFIGURE WITH OVERRIDE
EXEC sys.sp_configure N'show advanced options', N'0'  RECONFIGURE WITH OVERRIDE
GO
