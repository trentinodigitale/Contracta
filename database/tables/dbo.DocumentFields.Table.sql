USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[DocumentFields]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentFields](
	[dfIType] [smallint] NOT NULL,
	[dfISubtype] [smallint] NOT NULL,
	[dfFieldName] [varchar](50) NULL
) ON [PRIMARY]
GO
