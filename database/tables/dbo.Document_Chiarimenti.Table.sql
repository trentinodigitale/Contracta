USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Chiarimenti]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Chiarimenti](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ID_ORIGIN] [int] NULL,
	[DataCreazione] [datetime] NULL,
	[Domanda] [nvarchar](max) NULL,
	[Risposta] [nvarchar](max) NULL,
	[Allegato] [nvarchar](250) NULL,
	[UtenteDomanda] [int] NULL,
	[UtenteRisposta] [int] NULL,
	[DataUltimaMod] [datetime] NULL,
	[Stato] [varchar](100) NULL,
	[ChiarimentoPubblico] [tinyint] NULL,
	[aziragionesociale] [nvarchar](1000) NULL,
	[azitelefono1] [nvarchar](50) NULL,
	[azifax] [nvarchar](50) NULL,
	[azie_mail] [nvarchar](1000) NULL,
	[Protocol] [nvarchar](50) NULL,
	[ChiarimentoEvaso] [tinyint] NULL,
	[Notificato] [tinyint] NULL,
	[DataRisposta] [datetime] NULL,
	[ProtocolRispostaQuesito] [nvarchar](50) NULL,
	[Fascicolo] [nvarchar](100) NULL,
	[Document] [varchar](200) NULL,
	[DomandaOriginale] [nvarchar](max) NULL,
	[ProtocolloGenerale] [varchar](50) NULL,
	[DataProtocolloGenerale] [datetime] NULL,
	[StatoFunzionale] [varchar](50) NULL,
	[idPfuInCharge] [int] NULL,
	[ProtocolloGeneraleIN] [varchar](50) NULL,
	[DataProtocolloGeneraleIN] [datetime] NULL,
	[Pubblicazione_auto_Richiesta] [varchar](50) NULL,
	[StampaPDF] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Chiarimenti] ADD  CONSTRAINT [DF_Document_Chiarimenti_DataCreazione]  DEFAULT (getdate()) FOR [DataCreazione]
GO
ALTER TABLE [dbo].[Document_Chiarimenti] ADD  CONSTRAINT [DF_Document_Chiarimenti_DataUltimaMod]  DEFAULT (getdate()) FOR [DataUltimaMod]
GO
ALTER TABLE [dbo].[Document_Chiarimenti] ADD  CONSTRAINT [DF_Document_Chiarimenti_ChiarimentoPubblico]  DEFAULT ((0)) FOR [ChiarimentoPubblico]
GO
ALTER TABLE [dbo].[Document_Chiarimenti] ADD  CONSTRAINT [DF_Document_Chiarimenti_ChiarimentoEvaso_1]  DEFAULT ((0)) FOR [ChiarimentoEvaso]
GO
ALTER TABLE [dbo].[Document_Chiarimenti] ADD  CONSTRAINT [DF_Document_Chiarimenti_Notificato_1]  DEFAULT ((0)) FOR [Notificato]
GO
ALTER TABLE [dbo].[Document_Chiarimenti] ADD  CONSTRAINT [DF_Document_Chiarimenti_Document]  DEFAULT ('') FOR [Document]
GO
ALTER TABLE [dbo].[Document_Chiarimenti] ADD  CONSTRAINT [DF_Document_Chiarimenti_StatoFunzionale]  DEFAULT ('InLavorazione') FOR [StatoFunzionale]
GO
ALTER TABLE [dbo].[Document_Chiarimenti] ADD  CONSTRAINT [DF_Document_Chiarimenti_idPfuInCharge]  DEFAULT ((0)) FOR [idPfuInCharge]
GO
