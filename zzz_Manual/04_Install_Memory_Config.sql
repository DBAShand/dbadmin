-- ============================================================
-- 04_Install_Memory_Config.sql
-- Sets max/min server memory for a new SQL Server instance.
--
-- Default behavior: auto-calculates based on physical RAM.
--   <= 32 GB RAM  → max = RAM - 4 GB
--   >  32 GB RAM  → max = RAM * 90%
--   min           → always 0 (single instance assumption)
--
-- POWERSHELL TOKENS (optional override — leave 0 to use auto):
--   {{MAX_MEMORY_MB}}   e.g. 24576  (0 = auto-calculate)
--   {{MIN_MEMORY_MB}}   e.g. 0
--
-- NOTE: If this server hosts multiple SQL instances,
--       set {{MAX_MEMORY_MB}} and {{MIN_MEMORY_MB}} explicitly.
-- ============================================================

DECLARE @physicalmemory      BIGINT
DECLARE @sqlservermaxmemory  BIGINT = {{MAX_MEMORY_MB}}
DECLARE @sqlserverminmemory  BIGINT = {{MIN_MEMORY_MB}}

SELECT @physicalmemory = total_physical_memory_kb
FROM sys.dm_os_sys_memory

-- Auto-calculate max if not overridden
IF @sqlservermaxmemory < 10240
BEGIN
    IF @physicalmemory < 41943040   -- under 40 GB
        SET @sqlservermaxmemory = @physicalmemory - 4194304   -- leave 4 GB for OS
    ELSE
        SET @sqlservermaxmemory = @physicalmemory * .90       -- leave 10% for OS

    SET @sqlservermaxmemory = @sqlservermaxmemory / 1024
END

SET @sqlserverminmemory = @sqlserverminmemory / 1024

PRINT 'Min memory (MB): ' + CAST(@sqlserverminmemory AS VARCHAR)
PRINT 'Max memory (MB): ' + CAST(@sqlservermaxmemory AS VARCHAR)

EXEC sys.sp_configure N'show advanced options', N'1'
RECONFIGURE WITH OVERRIDE
EXEC sys.sp_configure N'max server memory (MB)', @sqlservermaxmemory
RECONFIGURE WITH OVERRIDE
EXEC sys.sp_configure N'min server memory (MB)', @sqlserverminmemory
RECONFIGURE WITH OVERRIDE
EXEC sys.sp_configure N'show advanced options', N'0'
RECONFIGURE WITH OVERRIDE
GO
