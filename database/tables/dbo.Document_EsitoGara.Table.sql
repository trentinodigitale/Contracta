USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_EsitoGara]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_EsitoGara](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[DataCreazione] [datetime] NULL,
	[ID_MSG_PDA] [int] NULL,
	[ID_MSG_BANDO] [int] NULL,
	[StatoEsclusione] [varchar](20) NULL,
	[Oggetto] [ntext] NULL,
	[DataAperturaOfferte] [datetime] NULL,
	[DataIISeduta] [datetime] NULL,
	[Segretario] [nvarchar](50) NULL,
	[Protocol] [varchar](50) NULL,
	[idAggiudicatrice] [int] NULL,
	[importoBaseAsta] [float] NULL,
	[NRDeterminazione] [varchar](50) NULL,
	[DataDetermina] [datetime] NULL,
	[ValutazioneEconomica] [float] NULL,
	[ProtocolloGenerale] [varchar](30) NULL,
	[DataProt] [datetime] NULL,
	[StatoGara] [varchar](20) NULL,
	[Versione] [int] NULL,
	[Segretario_Contratto] [nvarchar](50) NULL,
	[ProtocolloGenerale_Contratto] [varchar](30) NULL,
	[DataProt_Contratto] [datetime] NULL,
	[DataInvio] [datetime] NULL,
	[Protocollo] [varchar](100) NULL,
	[Titolo] [nvarchar](250) NULL,
	[IdPfu] [int] NULL,
	[StatoFunzionale] [varchar](50) NULL,
	[CanaleNotifica] [varchar](50) NULL,
	[StatoStipula] [varchar](50) NULL,
	[DataInvioStipula] [datetime] NULL,
	[ProtocolloStipula] [varchar](100) NULL,
	[TitoloStipula] [nvarchar](250) NULL,
 CONSTRAINT [PK_Document_EsitoGara] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_EsitoGara] ADD  CONSTRAINT [DF__Document___DataC__5D88F9D1]  DEFAULT (getdate()) FOR [DataCreazione]
GO
ALTER TABLE [dbo].[Document_EsitoGara] ADD  CONSTRAINT [DF__Document___Stato__5E7D1E0A]  DEFAULT ('Saved') FOR [StatoEsclusione]
GO
ALTER TABLE [dbo].[Document_EsitoGara] ADD  CONSTRAINT [DF_Document_EsitoGara_Versione]  DEFAULT (2) FOR [Versione]
GO
ALTER TABLE [dbo].[Document_EsitoGara] ADD  CONSTRAINT [DF_Document_EsitoGara_StatoFunzionale]  DEFAULT ('InLavorazione') FOR [StatoFunzionale]
GO
ALTER TABLE [dbo].[Document_EsitoGara] ADD  CONSTRAINT [DF_Document_EsitoGara_CanaleNotifica]  DEFAULT ('mail') FOR [CanaleNotifica]
GO
ALTER TABLE [dbo].[Document_EsitoGara] ADD  CONSTRAINT [DF_Document_EsitoGara_StatoStipula]  DEFAULT ('Saved') FOR [StatoStipula]
GO
