USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Esito_Pubblicazioni]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Esito_Pubblicazioni](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[Tipo] [varchar](20) NULL,
	[Pubblicazioni] [varchar](50) NULL,
	[NumeroPub] [int] NULL,
	[ComunePub] [varchar](50) NULL,
	[NumMod] [int] NULL,
	[Importo] [float] NULL,
	[Disponibilita] [varchar](20) NULL,
	[DataPubblicazione] [datetime] NULL,
	[DataPubblicazioneBando] [datetime] NULL,
	[Quotidiani] [varchar](50) NULL,
	[Fornitore] [varchar](50) NULL,
	[ResidualBudget] [float] NULL,
	[InBudget] [nvarchar](20) NULL,
	[TiketBudget] [int] NULL,
	[BDD_ID] [int] NULL,
	[NumeroImpegni] [varchar](50) NULL,
	[StatoEsitoRow] [varchar](20) NULL,
	[Liquida_Check] [varchar](50) NULL,
 CONSTRAINT [PK_Document_Esito_Pubblicazioni] PRIMARY KEY CLUSTERED 
(
	[idRow] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Esito_Pubblicazioni] ADD  CONSTRAINT [DF_Document_Esito_Pubblicazioni_Importo]  DEFAULT (0) FOR [Importo]
GO
ALTER TABLE [dbo].[Document_Esito_Pubblicazioni] ADD  CONSTRAINT [DF_Document_Esito_Pubblicazioni_BDD_ID]  DEFAULT ((-1)) FOR [BDD_ID]
GO
ALTER TABLE [dbo].[Document_Esito_Pubblicazioni] ADD  CONSTRAINT [DF_Document_Esito_Pubblicazioni_NumeroImpegni]  DEFAULT ('') FOR [NumeroImpegni]
GO
ALTER TABLE [dbo].[Document_Esito_Pubblicazioni] ADD  CONSTRAINT [DF_Document_Esito_Pubblicazioni_StatoEsito]  DEFAULT ('Saved') FOR [StatoEsitoRow]
GO
