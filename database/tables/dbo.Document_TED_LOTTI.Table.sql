USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_TED_LOTTI]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_TED_LOTTI](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[AzioneProposta] [varchar](100) NULL,
	[EsitoControlli] [nvarchar](max) NULL,
	[CIG] [varchar](50) NULL,
	[StatoRichiestaLOTTO] [varchar](100) NULL,
	[TED_LOT_NO] [int] NULL,
	[TED_TITOLO_APPALTO] [nvarchar](500) NULL,
	[TED_LUOGO_ESECUZIONE_PRINCIPALE] [varchar](100) NULL,
	[TED_CRITERIO_AGG_LOTTO] [int] NULL,
	[TED_TIPO_CRITERIO] [int] NULL,
	[TED_CRITERIO_COSTO] [nvarchar](max) NULL,
	[TED_CRITERIO_COSTO_TEC] [nvarchar](max) NULL,
	[TED_CRITERIO_PREZZO] [nvarchar](400) NULL,
	[TED_ACCETTATE_VARIANTI] [varchar](5) NULL,
	[TED_DESCRIZIONE_OPZIONI] [nvarchar](4000) NULL,
	[TED_PRES_OFFERTE_CATALOGO_ELETTRONICO] [varchar](5) NULL,
	[TED_FLAG_APPALTO_PROGETTO_UE] [varchar](5) NULL,
	[TED_APPALTO_PROGETTO_UE] [nvarchar](500) NULL,
	[NotEditable] [nvarchar](max) NULL,
	[IMPORTO_LOTTO] [decimal](18, 2) NULL,
	[IMPORTO_ATTUAZIONE_SICUREZZA] [decimal](18, 2) NULL,
	[IMPORTO_OPZIONI] [decimal](18, 2) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
