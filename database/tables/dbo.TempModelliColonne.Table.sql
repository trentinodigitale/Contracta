USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempModelliColonne]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempModelliColonne](
	[IdMcl] [int] NOT NULL,
	[mclIdMdl] [int] NOT NULL,
	[mclIdVatDefault] [int] NULL,
	[mclIdDzt] [int] NOT NULL,
	[mclModificabile] [bit] NOT NULL,
	[mclShadow] [bit] NOT NULL,
	[mclPosizione] [tinyint] NULL,
	[mclAllDefault] [int] NOT NULL,
	[mclPesoFvaDefault] [tinyint] NULL,
	[mclIdFvaDefault] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempModelliColonne] ADD  CONSTRAINT [DF_TempModelliColonne_mclShadow]  DEFAULT (0) FOR [mclShadow]
GO
ALTER TABLE [dbo].[TempModelliColonne] ADD  CONSTRAINT [DF_TempModelliColonne_mclAllDefault]  DEFAULT (1) FOR [mclAllDefault]
GO
