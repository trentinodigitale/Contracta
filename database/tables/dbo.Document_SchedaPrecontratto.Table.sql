USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_SchedaPrecontratto]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_SchedaPrecontratto](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DataCreazione] [datetime] NULL,
	[ID_MSG_PDA] [int] NULL,
	[ID_MSG_BANDO] [int] NULL,
	[Stato] [varchar](20) NULL,
	[ProtocolloBando] [varchar](50) NULL,
	[PubblicazioneEsito] [varchar](10) NULL,
	[idAggiudicatrice] [int] NULL,
	[deleted] [int] NULL,
	[Oggetto] [ntext] NULL,
	[NRDeterminazione] [varchar](50) NULL,
	[DataDetermina] [datetime] NULL,
	[DataEfficacia] [datetime] NULL,
	[IstruttoriaControlli] [ntext] NULL,
	[DataInvioCom] [datetime] NULL,
	[TipoInvioCom] [varchar](20) NULL,
	[DataUltimoInvioCom] [datetime] NULL,
	[TipoUltimoInvioCom] [varchar](20) NULL,
	[ImpugnazioniControEsclusione] [varchar](20) NULL,
	[DecorsiTerminiImpugnazione] [varchar](20) NULL,
	[NoteReportComunicazioneEsito] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_SchedaPrecontratto] ADD  CONSTRAINT [DF_Document_SchedaPrecontratto_Stato]  DEFAULT ('Saved') FOR [Stato]
GO
ALTER TABLE [dbo].[Document_SchedaPrecontratto] ADD  CONSTRAINT [DF_Document_SchedaPrecontratto_deleted]  DEFAULT (0) FOR [deleted]
GO
ALTER TABLE [dbo].[Document_SchedaPrecontratto] ADD  CONSTRAINT [DF_Document_SchedaPrecontratto_DataDetermina]  DEFAULT (getdate()) FOR [DataDetermina]
GO
