-- ============================================================
-- 10_createendpoints.sql
-- Creates the HADR mirroring endpoint and grants CONNECT
-- to all AG node service accounts.
-- Run on EVERY node in the availability group.
--
-- POWERSHELL TOKENS (replace before running):
--   {{ENDPOINT_PORT}}        e.g. 5022
--   {{DOMAIN}}               e.g. CONTOSO
--   {{NODE1_DE_ACCOUNT}}     Database Engine svc account, node 1
--   {{NODE1_AG_ACCOUNT}}     AG/SQLAgent svc account, node 1
--   {{NODE2_DE_ACCOUNT}}     Database Engine svc account, node 2
--   {{NODE2_AG_ACCOUNT}}     AG/SQLAgent svc account, node 2
--   {{NODE3_DE_ACCOUNT}}     (remove block if < 3 nodes)
--   {{NODE3_AG_ACCOUNT}}
--   {{NODE4_DE_ACCOUNT}}     (remove block if < 4 nodes)
--   {{NODE4_AG_ACCOUNT}}
-- ============================================================

USE [master]
GO

DECLARE @EndpointName  SYSNAME = 'Hadr_endpoint'
DECLARE @EndpointPort  INT     = {{ENDPOINT_PORT}}
DECLARE @Domain        SYSNAME = N'{{DOMAIN}}'

-- All service accounts that need CONNECT on this endpoint
DECLARE @ServiceAccounts TABLE (AccountName SYSNAME)
INSERT INTO @ServiceAccounts VALUES
    (@Domain + '\' + '{{NODE1_DE_ACCOUNT}}'),
    (@Domain + '\' + '{{NODE1_AG_ACCOUNT}}'),
    (@Domain + '\' + '{{NODE2_DE_ACCOUNT}}'),
    (@Domain + '\' + '{{NODE2_AG_ACCOUNT}}'),
    (@Domain + '\' + '{{NODE3_DE_ACCOUNT}}'),
    (@Domain + '\' + '{{NODE3_AG_ACCOUNT}}'),
    (@Domain + '\' + '{{NODE4_DE_ACCOUNT}}'),
    (@Domain + '\' + '{{NODE4_AG_ACCOUNT}}')

-- 1. Create endpoint if it doesn't exist
IF NOT EXISTS (SELECT name FROM sys.database_mirroring_endpoints WHERE name = @EndpointName)
BEGIN
    PRINT 'Creating endpoint ' + @EndpointName + ' on port ' + CAST(@EndpointPort AS VARCHAR)
    DECLARE @createSQL NVARCHAR(MAX) =
        'CREATE ENDPOINT [' + @EndpointName + ']
            STATE = STARTED
            AS TCP (LISTENER_PORT = ' + CAST(@EndpointPort AS VARCHAR) + ', LISTENER_IP = ALL)
            FOR DATA_MIRRORING (ROLE = ALL, AUTHENTICATION = WINDOWS NEGOTIATE, ENCRYPTION = REQUIRED ALGORITHM AES)'
    EXEC (@createSQL)
END
ELSE
    PRINT 'Endpoint ' + @EndpointName + ' already exists, skipping create.'

-- Transfer ownership to sa
DECLARE @authSQL NVARCHAR(MAX) = 'ALTER AUTHORIZATION ON ENDPOINT::' + @EndpointName + ' TO sa'
EXEC (@authSQL)

-- 2. Create logins and grant CONNECT for each service account
DECLARE @AccountName SYSNAME
DECLARE @sqlcmd      NVARCHAR(MAX)

DECLARE account_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT AccountName FROM @ServiceAccounts

OPEN account_cursor
FETCH NEXT FROM account_cursor INTO @AccountName

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sqlcmd = 'IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = N''' + @AccountName + ''')
        CREATE LOGIN [' + @AccountName + '] FROM WINDOWS WITH DEFAULT_DATABASE=[master]'
    EXEC (@sqlcmd)
    PRINT 'Login ensured: ' + @AccountName

    SET @sqlcmd = 'GRANT CONNECT ON ENDPOINT::[' + @EndpointName + '] TO [' + @AccountName + ']'
    EXEC (@sqlcmd)
    PRINT 'CONNECT granted: ' + @AccountName

    FETCH NEXT FROM account_cursor INTO @AccountName
END

CLOSE account_cursor
DEALLOCATE account_cursor

PRINT 'Endpoint setup complete on ' + @@SERVERNAME
GO
