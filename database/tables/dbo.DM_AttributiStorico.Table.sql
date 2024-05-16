USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[DM_AttributiStorico]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DM_AttributiStorico](
	[idApp] [tinyint] NOT NULL,
	[lnk] [int] NOT NULL,
	[vatiddzt] [int] NOT NULL,
	[vatidUMS] [int] NULL,
	[vatidUMSDscNome] [int] NULL,
	[vatidUMSDscSimbolo] [int] NULL,
	[dztNome] [varchar](50) NOT NULL,
	[dztMultiValue] [bit] NOT NULL,
	[dztIdTid] [smallint] NOT NULL,
	[vatValore_FT] [nvarchar](3000) NULL,
	[isDsccsx] [tinyint] NOT NULL,
	[vatTipoMem] [tinyint] NOT NULL,
	[DataValidita] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DM_AttributiStorico] ADD  CONSTRAINT [DF_DM_AttributiStorico_idApp]  DEFAULT (1) FOR [idApp]
GO
ALTER TABLE [dbo].[DM_AttributiStorico] ADD  CONSTRAINT [DF_DM_AttributiStorico_dztMultiValue]  DEFAULT (0) FOR [dztMultiValue]
GO
ALTER TABLE [dbo].[DM_AttributiStorico] ADD  CONSTRAINT [DF_DM_AttributiStorico_isDsccsx]  DEFAULT (0) FOR [isDsccsx]
GO
