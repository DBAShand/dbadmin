USE [DBAdmin]
GO

/****** Object:  StoredProcedure [scs].[scs_AG_PRIMARY_CREATE]    Script Date: 1/17/2018 10:34:54 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [scs].[scs_AG_PRIMARY_CREATE]
@primaryreplica sysname, 
@agname sysname, 
@numberofreplicas INT,
@database sysname = NULL,
@listener sysname = NULL,
@listener_ip_odc NVARCHAR(15) = NULL,
@listener_ip_kdc NVARCHAR(15) = NULL,
@scs_execute AS NCHAR(1) = 'N'
AS

DECLARE @replicacode VARCHAR(MAX)
DECLARE @replicacodeadd VARCHAR(MAX)
DECLARE @secondaryReplca SYSNAME
DECLARE @primaryreplicacount INT
DECLARE @failovertype NVARCHAR(20)
DECLARE @committype NVARCHAR(20)
DECLARE @hostfirst NVARCHAR(150)
DECLARE @CNT INT
DECLARE @AGCNT INT



SET @cnt = 2
SET @primaryreplicacount = @numberofreplicas / 2
SET @replicacode = 'USE MASTER;'

SET @AGCNT = (SELECT COUNT(NAME) FROM sys.availability_groups  WHERE NAME = @agname)

IF (SUBSTRING(@primaryreplica,1,1) = 'P')
BEGIN

IF  @AGCNT = 0
BEGIN

SET @replicacode = @replicacode + 
'
CREATE AVAILABILITY GROUP [' + @agname + ']
	WITH (AUTOMATED_BACKUP_PREFERENCE = PRIMARY)
	FOR REPLICA ON N''' + @primaryreplica +''' 
	WITH (ENDPOINT_URL = ''TCP://' + @primaryreplica + '.scs.root.mrc.local:5022'',
	FAILOVER_MODE = AUTOMATIC,
	SECONDARY_ROLE (ALLOW_CONNECTIONS = ALL), 
	AVAILABILITY_MODE = SYNCHRONOUS_COMMIT),
	'


WHILE @CNT <= @numberofreplicas
BEGIN
IF @cnt <= @primaryreplicacount
 BEGIN 
	SET @hostfirst = (SELECT LEFT(@primaryreplica,12) )
	SET @secondaryReplca = @hostfirst + CONVERT(CHAR,@cnt)
	--SET @host = (SELECT LEFT(@primaryreplica,12) + CONVERT(CHAR,@cnt))
END
ELSE
 BEGIN
    SET @hostfirst = (SELECT REPLACE (LEFT(@primaryreplica,12),'OW05C', 'KW05C'))
	SET @secondaryReplca = @hostfirst + CONVERT(CHAR,@cnt - @primaryreplicacount)

END
SET @secondaryReplca = (SELECT LEFT(@secondaryReplca,13))
SET @failovertype = 'MANUAL'
SET @committype = 'ASYNCHRONOUS_COMMIT'

IF (SUBSTRING(@secondaryReplca ,2,1) = 'O' AND @CNT < 3 ) OR (SUBSTRING(@secondaryReplca ,2,1) = 'K' AND  CONVERT(CHAR,@cnt - @primaryreplicacount) = 1)
BEGIN
IF ((SELECT @@version) LIKE '%2014%' AND @cnt <3) OR ((SELECT @@version) LIKE '%2016%')

begin
SET @failovertype = 'AUTOMATIC'
SET @committype = 'SYNCHRONOUS_COMMIT'
END
END
SET @replicacode = @replicacode	+ '
N''' + @secondaryReplca + ''' 
	WITH (ENDPOINT_URL = ''TCP://' + @secondaryReplca + '.scs.root.mrc.local:5022'',
	FAILOVER_MODE = ' + @failovertype + ',
	AVAILABILITY_MODE = ' + @committype + ',
	BACKUP_PRIORITY = 50,
	SECONDARY_ROLE(ALLOW_CONNECTIONS = ALL))'
IF @cnt < @numberofreplicas 
SET @replicacode = @replicacode + ',

'
SET @CNT = @CNT + 1
END
END


IF @listener IS NOT NULL AND @listener_ip_odc IS NOT NULL AND @listener_ip_kdc IS NOT NULL
   BEGIN
    SET @replicacode = @replicacode +   '
	
	ALTER AVAILABILITY GROUP [' + @agname + ']
	ADD LISTENER '''  + @listener + '''(
	WITH IP ( (''' + @listener_IP_ODC + ''', ''255.255.255.0''),
	(''' + @listener_IP_KDC + ''', ''255.255.255.0'')) ,
	PORT = 1433);
	
	'
	END
IF @database IS NOT NULL 
BEGIN

SET @replicacodeadd = 
'
USE MASTER;	
ALTER AVAILABILITY GROUP [' + @agname + ']
	ADD DATABASE [' + @database + ']'
END


END





IF (SUBSTRING(@primaryreplica,1,1) = 'U')
BEGIN
IF @AGCNT= 0
BEGIN

SET @replicacode = @replicacode + 
'
CREATE AVAILABILITY GROUP [' + @agname + ']
	WITH (AUTOMATED_BACKUP_PREFERENCE = PRIMARY)
	FOR REPLICA ON N''' + @primaryreplica +''' 
	WITH (ENDPOINT_URL = ''TCP://' + @primaryreplica + '.scs.root.mrc.local:5022'',
	FAILOVER_MODE = AUTOMATIC,
	SECONDARY_ROLE (ALLOW_CONNECTIONS = ALL), 
	AVAILABILITY_MODE = SYNCHRONOUS_COMMIT),
	'


WHILE @CNT <= @numberofreplicas
BEGIN
IF @cnt <= @primaryreplicacount
 BEGIN 
	SET @hostfirst = (SELECT LEFT(@primaryreplica,12) )
	SET @secondaryReplca = @hostfirst + CONVERT(CHAR,@cnt)
	--SET @host = (SELECT LEFT(@primaryreplica,12) + CONVERT(CHAR,@cnt))
END
ELSE
 BEGIN
    SET @hostfirst = (SELECT REPLACE (LEFT(@primaryreplica,12),'KW05C', 'OW05C'))
	SET @secondaryReplca = @hostfirst + CONVERT(CHAR,@cnt - @primaryreplicacount)

END
SET @secondaryReplca = (SELECT LEFT(@secondaryReplca,13))
SET @failovertype = 'MANUAL'
SET @committype = 'ASYNCHRONOUS_COMMIT'

IF (SUBSTRING(@secondaryReplca ,2,1) = 'K' AND @CNT < 3 ) OR (SUBSTRING(@secondaryReplca ,2,1) = 'O' AND  CONVERT(CHAR,@cnt - @primaryreplicacount) = 1)
BEGIN
IF ((SELECT @@version) LIKE '%2014%' AND @cnt <3) OR ((SELECT @@version) LIKE '%2016%')

BEGIN
SET @failovertype = 'AUTOMATIC'
SET @committype = 'SYNCHRONOUS_COMMIT'
END
END

SET @replicacode = @replicacode	+ '
N''' + @secondaryReplca + ''' 
	WITH (ENDPOINT_URL = ''TCP://' + @secondaryReplca + '.scs.root.mrc.local:5022'',
	FAILOVER_MODE = ' + @failovertype + ',
	AVAILABILITY_MODE = ' + @committype + ',
	BACKUP_PRIORITY = 50,
	SECONDARY_ROLE(ALLOW_CONNECTIONS = ALL))'
IF @cnt < @numberofreplicas 
SET @replicacode = @replicacode + ',
'
SET @CNT = @CNT + 1
END

END


IF @listener IS NOT NULL AND @listener_ip_odc IS NOT NULL AND @listener_ip_kdc IS NOT NULL
   BEGIN
    SET @replicacode = @replicacode +   '
	USE MASTER;
	ALTER AVAILABILITY GROUP [' + @agname + ']
	ADD LISTENER '''  + @listener + '''(
	WITH IP ( (''' + @listener_IP_KDC + ''', ''255.255.255.0''),
	(''' + @listener_IP_ODC + ''', ''255.255.255.0'')) ,
	PORT = 1433);
	'
	END
	

IF @database IS NOT NULL 
BEGIN
SET @replicacodeadd = 
'
USE MASTER;
ALTER AVAILABILITY GROUP [' + @agname + ']	ADD DATABASE [' + @database + ']'
END



END


PRINT @replicacode
IF @scs_execute = 'Y'
BEGIN
	EXECUTE (@replicacode)
	IF @database IS NOT NULL
    BEGIN
    EXECUTE (@replicacodeadd)
	END
END


GO


