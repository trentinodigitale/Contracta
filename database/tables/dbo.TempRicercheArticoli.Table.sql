USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempRicercheArticoli]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempRicercheArticoli](
	[racIdRic] [int] NOT NULL,
	[racIdArt] [int] NOT NULL,
	[racSegnato] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempRicercheArticoli] ADD  CONSTRAINT [DF_TempRicercheArticoli_racSegnato]  DEFAULT (0) FOR [racSegnato]
GO
