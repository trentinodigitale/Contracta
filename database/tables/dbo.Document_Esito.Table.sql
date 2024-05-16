USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Esito]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Esito](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[DataCreazione] [datetime] NULL,
	[ID_MSG_PDA] [int] NULL,
	[ID_MSG_BANDO] [int] NULL,
	[StatoEsito] [varchar](20) NULL,
	[Oggetto] [ntext] NULL,
	[DataAperturaOfferte] [datetime] NULL,
	[Protocol] [varchar](50) NULL,
	[idAggiudicatrice] [int] NULL,
	[ImportoComplessivoLavori] [float] NULL,
	[NRDeterminazione] [varchar](50) NULL,
	[DataDetermina] [datetime] NULL,
	[ValutazioneEconomica] [float] NULL,
	[StatoGara] [varchar](20) NULL,
	[NumeroOfferte] [int] NULL,
	[NumeroPratica] [int] NULL,
	[DataIndizione] [datetime] NULL,
	[NumeroIndizione] [varchar](50) NULL,
	[DurataLavori] [varchar](50) NULL,
	[DirettoreLavori] [varchar](50) NULL,
	[NRDeterminaEsito] [varchar](50) NULL,
	[DataDeterminaEsito] [datetime] NULL,
	[Valuta] [varchar](50) NULL,
	[InBudget] [nvarchar](20) NULL,
	[ResidualBudget] [int] NULL,
	[Esercizio] [varchar](50) NULL,
	[DatiBilancio] [varchar](50) NULL,
	[DataIISeduta] [datetime] NULL,
 CONSTRAINT [PK_Document_Esito] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Esito] ADD  CONSTRAINT [DF__Document___DataC__2A824FCA]  DEFAULT (getdate()) FOR [DataCreazione]
GO
ALTER TABLE [dbo].[Document_Esito] ADD  CONSTRAINT [DF__Document___Stato__2B767403]  DEFAULT ('Saved') FOR [StatoEsito]
GO
ALTER TABLE [dbo].[Document_Esito] ADD  CONSTRAINT [DF_Document_Esito_Valuta]  DEFAULT ('1') FOR [Valuta]
GO
