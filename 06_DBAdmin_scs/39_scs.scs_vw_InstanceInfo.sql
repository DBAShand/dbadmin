USE DBADmin
GO
CREATE VIEW scs.scs_vw_InstanceInfo AS
SELECT  A.ServerName ,
        C.[OS] ,
        A.[dbName] ,
        A.[Status] ,
        A.[DataFiles] ,
        A.[LogFiles] ,
        A.[Data MB] ,
        A.[Log MB] ,
        A.[Recovery model] ,
        A.[Date Data Collected] ,
        A.[AG_Name] ,
        A.[AG_Role] ,
        A.[AG_Role_Desc] ,
        A.[AG_BU_Pref] ,
        B.[LogicalName] ,
        B.[Size_MBs] ,
        B.[Size_GBs] ,
        B.[PhysicalFileLocation] ,
        B.[Drive] ,
        B.[FreeSpaceInMB] ,
        B.[TotalSpaceInMB] ,
        B.[FreeSpaceInGB] ,
        B.[TotalSpaceInGB] ,
        B.[PercentFree]
FROM    ( SELECT    @@SERVERNAME AS [ServerName] ,
                    [dbName] ,
                    [Status] ,
                    [DataFiles] ,
                    [LogFiles] ,
                    [Data MB] ,
                    [Log MB] ,
                    [Recovery model] ,
                    [Date Data Collected] ,
                    [AG_Name] ,
                    [AG_Role] ,
                    [AG_Role_Desc] ,
                    [AG_BU_Pref]
          FROM      [DBAdmin].[scs].[scs_vw_DBInfo]
        ) A
        INNER JOIN ( SELECT @@SERVERNAME AS [ServerName] ,
                            [LogicalName] ,
                            [DBName] ,
                            [Size_MBs] ,
                            [Size_GBs] ,
                            [PhysicalFileLocation] ,
                            [Drive] ,
                            [FreeSpaceInMB] ,
                            [TotalSpaceInMB] ,
                            [FreeSpaceInGB] ,
                            [TotalSpaceInGB] ,
                            [PercentFree] ,
                            [TimeStamp]
                     FROM   [DBAdmin].[scs].[scs_vw_DriveSpaceAuditWithDBs]
                   ) B ON A.ServerName = B.ServerName
                          AND A.dbName = B.DBName
        INNER JOIN ( SELECT @@SERVERNAME AS [ServerName] ,
                           CONCAT(CONCAT('Microsoft ',
                                          CASE windows_release
                                            WHEN '3.10'
                                            THEN 'Windows NT 3.1 ('
                                            WHEN '3.50'
                                            THEN 'Windows NT 3.5 ('
                                            WHEN '3.51'
                                            THEN 'Windows NT 3.51 ('
                                            WHEN '4.0' THEN 'Windows NT 4.0 ('
                                            WHEN '5.0' THEN 'Windows 2000 ('
                                            WHEN '5.1'
                                            THEN 'Windows Server 2003 ('
                                            WHEN '5.2'
                                            THEN 'Windows Server 2003 R2 ('
                                            WHEN '3.50'
                                            THEN 'Windows NT 3.5 ('
                                            WHEN '3.10'
                                            THEN 'Windows NT 3.1 ('
                                            WHEN '6.0'
                                            THEN 'Windows Server 2008 ('
                                            WHEN '6.1'
                                            THEN 'Windows Server 2008 R2 ('
                                            WHEN '6.2'
                                            THEN 'Windows Server 2012 ('
                                            WHEN '6.3'
                                            THEN 'Windows Server 2012 R2 ('
                                          END),
                                   CONCAT('Microsoft ',
                                          RIGHT(@@version,
                                                LEN(@@version) - 3
                                                - CHARINDEX(' ON ', @@VERSION))),
                                   ')') AS [OS]
                     FROM   sys.dm_os_windows_info
                   ) C ON C.ServerName = A.ServerName;
