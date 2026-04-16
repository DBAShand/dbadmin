USE [DBAdmin]
GO

/****** Object:  Table [dbo].[db_percentfree]    Script Date: 10/23/2017 9:51:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [maint].[db_percentfree](
    [dbname] [sysname],
	[db_files] [VARCHAR](300) NULL,
	[file_loc] [VARCHAR](300) NULL,
	[filesizeMB] [DECIMAL](9, 2) NULL,
	[spaceUsedMB] [DECIMAL](9, 2) NULL,
	[FreespaceMB] [DECIMAL](9, 2) NULL,
	[PercentSpaceFree] [DECIMAL](9, 2) NULL,
	[rundatetime] [DATETIME] NULL

) ON [PRIMARY]
