USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Programmazione_Iniziativa]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Programmazione_Iniziativa](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[EsitoRiga] [nvarchar](max) NULL,
	[Descrizione] [nvarchar](500) NULL,
	[Area_Organizzativa_Responsabile] [varchar](500) NULL,
	[Ruolo_DRCA] [varchar](500) NULL,
	[CategoriaDiSpesa] [varchar](100) NULL,
	[AREA_MERCEOLOGICA] [varchar](200) NULL,
	[Target_Iniziativa] [varchar](200) NULL,
	[DPCM] [varchar](50) NULL,
	[CATEGORIE_MERC] [varchar](100) NULL,
	[Strumento_Di_Acquisto] [varchar](100) NULL,
	[Trimestre_Di_Indizione] [varchar](50) NULL,
	[Anno_Previsto_Di_Indizione] [int] NULL,
	[Trimestre_Di_Indizione_PrimaAgg] [varchar](50) NULL,
	[Anno_Previsto_Agg] [int] NULL,
	[Trimestre_Previsto_Prima_Attivazione] [varchar](50) NULL,
	[Anno_Previsto_Attivazione] [int] NULL,
	[Importo_Presunto] [float] NULL,
	[Durata_Strumento_Di_Acquisto] [nvarchar](500) NULL,
	[Durata_Contratti] [nvarchar](500) NULL,
	[Gara_Aggregata_Altri_Soggetti] [nvarchar](500) NULL,
	[Id_Iniziativa_Precedente] [varchar](100) NULL,
	[Data_Scadenza_Prima_Convenzione] [datetime] NULL,
	[Data_Scadenza_Ultima_Convenzione] [datetime] NULL,
	[Importo_Totale_Iniziativa_Precedente] [float] NULL,
	[Importo_Eroso_Iniziativa_Precedente] [float] NULL,
	[DescTipoProceduraIniziativa] [nvarchar](100) NULL,
	[UserRUP] [int] NULL,
	[MotivazioniAnnullamento] [varchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
