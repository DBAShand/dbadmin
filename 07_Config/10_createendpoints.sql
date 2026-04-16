




DECLARE @hostname sysname = (SELECT @@servername)

DECLARE @envrioment CHAR(1)
DECLARE @cluster CHAR(2)
DECLARE @application CHAR(1)
DECLARE @primaryprimaryde sysname
DECLARE @primaryprimaryag sysname
DECLARE @primarysecondaryde sysname
DECLARE @primarysecondaryag sysname


DECLARE @secondaryprimaryde sysname
DECLARE @secondaryprimaryag sysname
DECLARE @secondarysecondaryde sysname
DECLARE @secondarysecondaryag sysname
DECLARE @sqlcmd NVARCHAR(max)


SET @application = SUBSTRING(@hostname,11,1) 
SET @envrioment = SUBSTRING(@hostname,1,1)
SET @CLUSTER = SUBSTRING(@hostname,7,2)
PRINT @envrioment
PRINT @cluster
PRINT @application
SET @primaryprimaryde = 'scs\SQL' + @envrioment + @cluster + 'DEO' + @application + '01'
SET @primaryprimaryag = 'scs\SQL' + @envrioment + @cluster + 'AGO' + @application + '01'
SET @primarysecondaryde = 'scs\SQL' + @envrioment + @cluster + 'DEO' + @application + '02'
SET @primarysecondaryag = 'scs\SQL' + @envrioment + @cluster + 'AGO' + @application + '02'


SET @secondaryprimaryde = 'scs\SQL' + @envrioment + @cluster + 'DEK' + @application + '01'
SET @secondaryprimaryag = 'scs\SQL' + @envrioment + @cluster + 'AGK' + @application + '01'
SET @secondarysecondaryde = 'scs\SQL' + @envrioment + @cluster + 'DEK' + @application + '02'
SET @secondarysecondaryag = 'scs\SQL' + @envrioment + @cluster + 'AGK' + @application + '02'

print @primaryprimaryde 
print @primaryprimaryag 
print @primarysecondaryde 
print @primarysecondaryde 


print @secondaryprimaryde 
print @secondaryprimaryag 
print @secondarysecondaryde
print @secondarysecondaryde
USE [master]

IF NOT EXISTS (SELECT name FROM sys.database_mirroring_endpoints WHERE name = 'Hadr_endpoint') 
	BEGIN 
	PRINT 'Creating endpoint Hadr_endpoint with port 5022'
	CREATE ENDPOINT [Hadr_endpoint] 
		STATE=STARTED
		AS TCP (LISTENER_PORT = 5022, LISTENER_IP = ALL)
		FOR DATA_MIRRORING (ROLE = ALL, AUTHENTICATION = WINDOWS NEGOTIATE
	, ENCRYPTION = REQUIRED ALGORITHM AES)
	END

ALTER AUTHORIZATION ON ENDPOINT::Hadr_endpoint TO sa;
SET @sqlcmd =	'IF NOT EXISTS (SELECT NAME FROM sys.syslogins WHERE NAME = ''' +  @primaryprimaryde + ''') CREATE LOGIN  [' +  @primaryprimaryde + '] FROM WINDOWS WITH DEFAULT_DATABASE=[master]' + CHAR(10) + 
			'IF NOT EXISTS (SELECT NAME FROM sys.syslogins WHERE NAME = ''' + @primaryprimaryag + ''') CREATE LOGIN  [' +  @primaryprimaryag + '] FROM WINDOWS WITH DEFAULT_DATABASE=[master]' + CHAR(10) + 
			'IF NOT EXISTS (SELECT NAME FROM sys.syslogins WHERE NAME = ''' +  @primarysecondaryde + ''') CREATE LOGIN  [' +  @primarysecondaryde + '] FROM WINDOWS WITH DEFAULT_DATABASE=[master]' + CHAR(10) + 
			'IF NOT EXISTS (SELECT NAME FROM sys.syslogins WHERE NAME = ''' + @primarysecondaryag + ''') CREATE LOGIN  [' +  @primarysecondaryag + '] FROM WINDOWS WITH DEFAULT_DATABASE=[master]' + CHAR(10) + 
			'IF NOT EXISTS (SELECT NAME FROM sys.syslogins WHERE NAME = ''' + @secondaryprimaryde + ''') CREATE LOGIN  [' +  @secondaryprimaryde + '] FROM WINDOWS WITH DEFAULT_DATABASE=[master]' + CHAR(10) + 
			'IF NOT EXISTS (SELECT NAME FROM sys.syslogins WHERE NAME = ''' + @secondaryprimaryag + ''') CREATE LOGIN  [' +  @secondaryprimaryag + '] FROM WINDOWS WITH DEFAULT_DATABASE=[master]' + CHAR(10) + 
			'IF NOT EXISTS (SELECT NAME FROM sys.syslogins WHERE NAME = ''' + @secondarysecondaryde + ''') CREATE LOGIN  [' +  @secondarysecondaryde + '] FROM WINDOWS WITH DEFAULT_DATABASE=[master]' + CHAR(10) + 
			'IF NOT EXISTS (SELECT NAME FROM sys.syslogins WHERE NAME = ''' + @secondarysecondaryag + ''') CREATE LOGIN  [' +  @secondarysecondaryag + '] FROM WINDOWS WITH DEFAULT_DATABASE=[master]' + CHAR(10) + 
			'GRANT CONNECT ON ENDPOINT::Hadr_endpoint TO [' +  @primaryprimaryde + '] ' + CHAR(10) + 
			'GRANT CONNECT ON ENDPOINT::Hadr_endpoint TO [' +  @primaryprimaryag + ']' + CHAR(10) + 
			'GRANT CONNECT ON ENDPOINT::Hadr_endpoint TO [' +  @primarysecondaryde + ']' + CHAR(10) + 
			'GRANT CONNECT ON ENDPOINT::Hadr_endpoint TO [' +  @primarysecondaryag + ']' + CHAR(10) + 
			'GRANT CONNECT ON ENDPOINT::Hadr_endpoint TO [' +  @secondaryprimaryde + ']' + CHAR(10) + 
			'GRANT CONNECT ON ENDPOINT::Hadr_endpoint TO [' +  @secondaryprimaryag + ']' + CHAR(10) + 
			'GRANT CONNECT ON ENDPOINT::Hadr_endpoint TO [' +  @secondarysecondaryde + ']' + CHAR(10) + 
			'GRANT CONNECT ON ENDPOINT::Hadr_endpoint TO [' +  @secondarysecondaryag + ']' 


PRINT @sqlcmd
EXEC (@sqlcmd)
