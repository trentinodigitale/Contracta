USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Profili_Funzionalita]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Profili_Funzionalita](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[NomeProfilo] [varchar](100) NOT NULL,
	[TipoProfilo] [varchar](20) NOT NULL,
	[Funzionalita] [varchar](1000) NULL,
	[Deleted] [bit] NOT NULL,
	[aziProfilo] [varchar](5) NULL,
	[Descrizione] [nvarchar](1000) NULL,
	[Codice] [varchar](100) NULL,
	[DataUltimaMod] [datetime] NULL,
	[sysDeleted] [bit] NOT NULL,
	[MP] [varchar](10) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Profili_Funzionalita] ADD  CONSTRAINT [DF_Profili_Funzionalita_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[Profili_Funzionalita] ADD  CONSTRAINT [DF_Profili_Funzionalita_DataUltimaMod]  DEFAULT (getdate()) FOR [DataUltimaMod]
GO
ALTER TABLE [dbo].[Profili_Funzionalita] ADD  CONSTRAINT [DF_Profili_Funzionalita_sysDeleted]  DEFAULT ((0)) FOR [sysDeleted]
GO
