USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempModelliArticoli]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempModelliArticoli](
	[IdMar] [int] NOT NULL,
	[marIdMgr] [int] NOT NULL,
	[marIdArt] [int] NOT NULL,
	[marScore] [smallint] NULL
) ON [PRIMARY]
GO
