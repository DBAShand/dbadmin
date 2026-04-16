USE [DBAdmin]
GO

/****** Object:  Table [scs].[Version]    Script Date: 6/6/2017 3:58:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [scs].[Version](
       [Version] [decimal](10, 9) NOT NULL,
       [LastUpdatedDate] [date] NOT NULL
) ON [PRIMARY]

GO
