USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Com_Aggiudicataria]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Com_Aggiudicataria](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DataCreazione] [datetime] NULL,
	[ID_MSG_PDA] [int] NULL,
	[ID_MSG_BANDO] [int] NULL,
	[Stato] [varchar](20) NULL,
	[Oggetto] [ntext] NULL,
	[ResponsabileContratto] [nvarchar](50) NULL,
	[Protocol] [varchar](50) NULL,
	[idAggiudicatrice] [int] NULL,
	[importoBaseAsta] [float] NULL,
	[NRDeterminazione] [varchar](50) NULL,
	[DataDetermina] [datetime] NULL,
	[ValutazioneEconomica] [float] NULL,
	[ProtocolloGenerale] [varchar](30) NULL,
	[DataProt] [datetime] NULL,
	[DirProponente] [nvarchar](250) NULL,
	[FaxProponente] [varchar](20) NULL,
	[FaxRUP] [varchar](20) NULL,
	[ImportoAggiudicato] [float] NULL,
	[OneriSic] [float] NULL,
	[OneriSicE] [float] NULL,
	[OneriSicI] [float] NULL,
	[OneriDis] [float] NULL,
	[LavoriEconomia] [float] NULL,
	[PercCauzione] [float] NULL,
	[CauzioneDefinitiva] [float] NULL,
	[CauzioneRidotta] [float] NULL,
	[RUP] [nvarchar](255) NULL,
	[NomeProponente] [nvarchar](100) NULL,
	[DataInvio] [datetime] NULL,
	[IdPfu] [int] NULL,
	[Titolo] [nvarchar](150) NULL,
	[StatoFunzionale] [varchar](50) NULL,
	[Protocollo] [varchar](50) NULL,
	[CanaleNotifica] [varchar](50) NULL,
 CONSTRAINT [PK_Document_Com_Aggiudicataria] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Com_Aggiudicataria] ADD  CONSTRAINT [DF_Document_Com_Aggiudicataria_DataCreazione]  DEFAULT (getdate()) FOR [DataCreazione]
GO
ALTER TABLE [dbo].[Document_Com_Aggiudicataria] ADD  CONSTRAINT [DF_Document_Com_Aggiudicataria_Stato]  DEFAULT ('Saved') FOR [Stato]
GO
ALTER TABLE [dbo].[Document_Com_Aggiudicataria] ADD  CONSTRAINT [DF_Document_Com_Aggiudicataria_StatoFunzionale]  DEFAULT ('InLavorazione') FOR [StatoFunzionale]
GO
ALTER TABLE [dbo].[Document_Com_Aggiudicataria] ADD  CONSTRAINT [DF_Document_Com_Aggiudicataria_CanaleNotifica]  DEFAULT ('mail') FOR [CanaleNotifica]
GO
