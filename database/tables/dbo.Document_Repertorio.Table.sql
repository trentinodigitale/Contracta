USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Repertorio]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Repertorio](
	[IdRepertorio] [int] IDENTITY(1,1) NOT NULL,
	[Conto] [varchar](20) NULL,
	[Oggetto] [text] NULL,
	[Rep] [int] NULL,
	[NaturaAtto] [varchar](30) NULL,
	[TipoContratto] [varchar](30) NULL,
	[DataStipula] [datetime] NULL,
	[DataInizio] [datetime] NULL,
	[DataFine] [datetime] NULL,
	[DurataAnni] [int] NULL,
	[Serie] [varchar](50) NULL,
	[NumRegistrazione] [varchar](50) NULL,
	[DataRegistrazione] [datetime] NULL,
	[Corrispettivo] [float] NULL,
	[DepositoCauzionale] [float] NULL,
	[UfficioRegistro] [varchar](50) NULL,
	[UffRogante] [varchar](50) NULL,
	[Importo] [float] NULL,
	[TassaRegistrazione] [float] NULL,
	[NumMarche] [int] NULL,
	[ValMarche] [float] NOT NULL,
	[ImportoMarche] [float] NULL,
	[DirittiSegreteria] [float] NULL,
	[DirittiAccesso] [float] NULL,
	[DirittiRogito] [float] NULL,
	[SpesePostali] [float] NULL,
	[Saldo] [float] NULL,
	[StatoRepertorio] [varchar](50) NULL,
	[NoteProgetto] [text] NULL,
	[NumMarche2] [int] NULL,
	[ValMarche2] [float] NOT NULL,
	[ImportoMarche2] [float] NULL,
	[NumReversale] [int] NULL,
	[DataReversale] [datetime] NULL,
	[ImportoComplessivo] [float] NULL,
	[idAggiudicatrice] [int] NULL,
	[ProtocolloBando] [varchar](50) NULL,
	[idDocSchedaPrecontratto] [int] NULL,
	[ImportoDaVersare] [float] NULL,
	[Esercizio] [varchar](20) NULL,
	[DatiBilancio] [varchar](20) NULL,
	[Versione] [tinyint] NOT NULL,
	[NumImpegno] [varchar](10) NULL,
 CONSTRAINT [PK_Document_Repertorio] PRIMARY KEY CLUSTERED 
(
	[IdRepertorio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Repertorio] ADD  CONSTRAINT [DF_Document_Repertorio_Conto]  DEFAULT ('70000-') FOR [Conto]
GO
ALTER TABLE [dbo].[Document_Repertorio] ADD  CONSTRAINT [DF_Document_Repertorio_ValMarche]  DEFAULT (14.62) FOR [ValMarche]
GO
ALTER TABLE [dbo].[Document_Repertorio] ADD  CONSTRAINT [DF_Document_Repertorio_StatoRepertorio]  DEFAULT ('InCorso') FOR [StatoRepertorio]
GO
ALTER TABLE [dbo].[Document_Repertorio] ADD  CONSTRAINT [DF_Document_Repertorio_ValMarche2]  DEFAULT (1.04) FOR [ValMarche2]
GO
ALTER TABLE [dbo].[Document_Repertorio] ADD  DEFAULT (2) FOR [Versione]
GO
