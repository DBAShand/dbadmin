USE [DBAdmin]
GO
/****** Object:  Table [scs].[backupset]    Script Date: 11/8/2026 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[scs].[backupset]') AND type = N'U')
BEGIN
	CREATE TABLE [scs].[backupset](
		[backup_set_id] [int] IDENTITY(1,1) NOT NULL,
		[backup_set_uuid] [uniqueidentifier] NOT NULL,
		[media_set_id] [int] NOT NULL,
		[first_family_number] [tinyint] NULL,
		[first_media_number] [smallint] NULL,
		[last_family_number] [tinyint] NULL,
		[last_media_number] [smallint] NULL,
		[catalog_family_number] [tinyint] NULL,
		[catalog_media_number] [smallint] NULL,
		[position] [int] NULL,
		[expiration_date] [datetime] NULL,
		[software_vendor_id] [int] NULL,
		[name] [nvarchar](128) NULL,
		[description] [nvarchar](255) NULL,
		[user_name] [nvarchar](128) NULL,
		[software_major_version] [tinyint] NULL,
		[software_minor_version] [tinyint] NULL,
		[software_build_version] [smallint] NULL,
		[time_zone] [smallint] NULL,
		[mtf_minor_version] [tinyint] NULL,
		[first_lsn] [numeric](25, 0) NULL,
		[last_lsn] [numeric](25, 0) NULL,
		[checkpoint_lsn] [numeric](25, 0) NULL,
		[database_backup_lsn] [numeric](25, 0) NULL,
		[database_creation_date] [datetime] NULL,
		[backup_start_date] [datetime] NULL,
		[backup_finish_date] [datetime] NULL,
		[type] [char](1) NULL,
		[sort_order] [smallint] NULL,
		[code_page] [smallint] NULL,
		[compatibility_level] [tinyint] NULL,
		[database_version] [int] NULL,
		[backup_size] [numeric](20, 0) NULL,
		[database_name] [nvarchar](128) NULL,
		[server_name] [nvarchar](128) NULL,
		[machine_name] [nvarchar](128) NULL,
		[flags] [int] NULL,
		[unicode_locale] [int] NULL,
		[unicode_compare_style] [int] NULL,
		[collation_name] [nvarchar](128) NULL,
		[is_password_protected] [bit] NULL,
		[recovery_model] [nvarchar](60) NULL,
		[has_bulk_logged_data] [bit] NULL,
		[is_snapshot] [bit] NULL,
		[is_readonly] [bit] NULL,
		[is_single_user] [bit] NULL,
		[has_backup_checksums] [bit] NULL,
		[is_damaged] [bit] NULL,
		[begins_log_chain] [bit] NULL,
		[has_incomplete_metadata] [bit] NULL,
		[is_force_offline] [bit] NULL,
		[is_copy_only] [bit] NULL,
		[first_recovery_fork_guid] [uniqueidentifier] NULL,
		[last_recovery_fork_guid] [uniqueidentifier] NULL,
		[fork_point_lsn] [numeric](25, 0) NULL,
		[database_guid] [uniqueidentifier] NULL,
		[family_guid] [uniqueidentifier] NULL,
		[differential_base_lsn] [numeric](25, 0) NULL,
		[differential_base_guid] [uniqueidentifier] NULL,
		[compressed_backup_size] [numeric](20, 0) NULL,
		[key_algorithm] [nvarchar](32) NULL,
		[encryptor_thumbprint] [varbinary](20) NULL,
		[encryptor_type] [nvarchar](32) NULL,
		[last_valid_restore_time] [datetime] NULL,
		[compression_algorithm] [nvarchar](32) NULL,
	 CONSTRAINT [PK_backupset] PRIMARY KEY CLUSTERED
	(
		[backup_set_id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]

	CREATE NONCLUSTERED INDEX [backupsetuuid] ON [scs].[backupset]
	(
		[backup_set_uuid] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

	CREATE NONCLUSTERED INDEX [backupsetDate] ON [scs].[backupset]
	(
		[backup_finish_date] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

	CREATE NONCLUSTERED INDEX [backupsetMediaSetId] ON [scs].[backupset]
	(
		[media_set_id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

	CREATE NONCLUSTERED INDEX [backupsetDatabaseName] ON [scs].[backupset]
	(
		[database_name] ASC
	)
	INCLUDE ([backup_set_id], [media_set_id])
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

	ALTER TABLE [scs].[backupset] WITH CHECK ADD CONSTRAINT [FK_backupset_media_set_id] FOREIGN KEY([media_set_id])
	REFERENCES [scs].[backupmediaset] ([media_set_id])
END
GO
