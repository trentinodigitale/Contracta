USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MessageStatus]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MessageStatus](
	[IdMsg] [int] NOT NULL,
	[IdSource] [int] NOT NULL,
	[SectionName] [varchar](255) NOT NULL,
	[Status] [tinyint] NOT NULL
) ON [PRIMARY]
GO
