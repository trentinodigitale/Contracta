USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[AFTableUsage]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AFTableUsage](
	[tuName] [varchar](255) NULL,
	[tuRows] [int] NULL,
	[tuReserved] [varchar](255) NULL,
	[tuData] [varchar](255) NULL,
	[tuIndexSize] [varchar](255) NULL,
	[tuUnused] [varchar](255) NULL
) ON [PRIMARY]
GO
