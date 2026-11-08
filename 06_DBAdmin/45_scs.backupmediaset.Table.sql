USE [DBAdmin]
GO
/****** Object:  Table [scs].[backupmediaset]    Script Date: 11/8/2026 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[scs].[backupmediaset]') AND type = N'U')
BEGIN
	CREATE TABLE [scs].[backupmediaset](
		[media_set_id] [int] IDENTITY(1,1) NOT NULL,
		[media_uuid] [uniqueidentifier] NULL,
		[media_family_count] [tinyint] NULL,
		[name] [nvarchar](128) NULL,
		[description] [nvarchar](255) NULL,
		[software_name] [nvarchar](128) NULL,
		[software_vendor_id] [int] NULL,
		[MTF_major_version] [tinyint] NULL,
		[mirror_count] [tinyint] NULL,
		[is_password_protected] [bit] NULL,
		[is_compressed] [bit] NULL,
		[is_encrypted] [bit] NULL,
	 CONSTRAINT [PK_backupmediaset] PRIMARY KEY CLUSTERED
	(
		[media_set_id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]

	CREATE NONCLUSTERED INDEX [backupmediasetuuid] ON [scs].[backupmediaset]
	(
		[media_uuid] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END
GO
