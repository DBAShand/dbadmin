
USE [DBAdmin]
GO

/****** Object:  Table [scs].[scs_Logins]    Script Date: 6/13/2017 11:40:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[scs].[scs_Logins]') AND type in (N'U'))
BEGIN
CREATE TABLE [scs].[scs_Logins](
	[LoginID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [sysname] NOT NULL,
	[SID] [varbinary](85) NOT NULL,
	[IsDisabled] [int] NOT NULL,
	[Type] [char](1) NOT NULL,
	[PasswordHash] [varbinary](256) NULL,
	[default_database_name] [sysname] NULL,
	[servername] [sysname] NOT NULL,
	[timestamp] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[LoginID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO


