USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempModelliArticoliXColonne]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempModelliArticoliXColonne](
	[macIdMar] [int] NOT NULL,
	[macIdMcl] [int] NOT NULL,
	[macIdVat] [int] NOT NULL,
	[macScore] [smallint] NULL
) ON [PRIMARY]
GO
