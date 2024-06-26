USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_SIMOG_GARA]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_SIMOG_GARA](
	[idrow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[indexCollaborazione] [int] NULL,
	[ID_STAZIONE_APPALTANTE] [varchar](100) NULL,
	[DENOM_STAZIONE_APPALTANTE] [nvarchar](max) NULL,
	[CF_AMMINISTRAZIONE] [varchar](20) NULL,
	[DENOM_AMMINISTRAZIONE] [nvarchar](max) NULL,
	[CF_UTENTE] [varchar](50) NULL,
	[IMPORTO_GARA] [decimal](18, 2) NULL,
	[TIPO_SCHEDA] [varchar](20) NULL,
	[MODO_REALIZZAZIONE] [varchar](20) NULL,
	[NUMERO_LOTTI] [int] NULL,
	[ESCLUSO_AVCPASS] [varchar](20) NULL,
	[URGENZA_DL133] [varchar](20) NULL,
	[CATEGORIE_MERC] [varchar](max) NULL,
	[ID_SCELTA_CONTRAENTE] [varchar](20) NULL,
	[StatoRichiestaGARA] [varchar](20) NULL,
	[EsitoControlli] [nvarchar](max) NULL,
	[id_gara] [varchar](50) NULL,
	[idpfuRup] [int] NULL,
	[MOTIVAZIONE_CIG] [varchar](20) NULL,
	[MOTIVO_CANCELLAZIONE_GARA] [varchar](20) NULL,
	[AzioneProposta] [varchar](20) NULL,
	[STRUMENTO_SVOLGIMENTO] [varchar](5) NULL,
	[ESTREMA_URGENZA] [varchar](5) NULL,
	[MODO_INDIZIONE] [varchar](5) NULL,
	[ALLEGATO_IX] [varchar](2) NULL,
	[DURATA_ACCQUADRO_CONVENZIONE] [int] NULL,
	[CIG_ACC_QUADRO] [varchar](20) NULL,
	[NotEditable] [varchar](4000) NULL,
	[DATA_PERFEZIONAMENTO_BANDO] [varchar](100) NULL,
	[LINK_AFFIDAMENTO_DIRETTO] [nvarchar](500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
