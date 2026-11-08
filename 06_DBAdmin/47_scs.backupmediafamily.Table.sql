USE [DBAdmin]
GO
/****** Object:  Table [scs].[backupmediafamily]    Script Date: 11/8/2026 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[scs].[backupmediafamily]') AND type = N'U')
BEGIN
	CREATE TABLE [scs].[backupmediafamily](
		[media_set_id] [int] NOT NULL,
		[family_sequence_number] [tinyint] NOT NULL,
		[media_family_id] [uniqueidentifier] NULL,
		[media_count] [int] NULL,
		[logical_device_name] [nvarchar](128) NULL,
		[physical_device_name] [nvarchar](260) NULL,
		[device_type] [tinyint] NULL,
		[physical_block_size] [int] NULL,
		[mirror] [tinyint] NOT NULL CONSTRAINT [DF_backupmediafamily_mirror] DEFAULT ((0)),
	 CONSTRAINT [PK_backupmediafamily] PRIMARY KEY CLUSTERED
	(
		[media_set_id] ASC,
		[family_sequence_number] ASC,
		[mirror] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]

	CREATE NONCLUSTERED INDEX [backupmediafamilyuuid] ON [scs].[backupmediafamily]
	(
		[media_family_id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

	ALTER TABLE [scs].[backupmediafamily] WITH CHECK ADD CONSTRAINT [FK_backupmediafamily_media_set_id] FOREIGN KEY([media_set_id])
	REFERENCES [scs].[backupmediaset] ([media_set_id])
END
GO
