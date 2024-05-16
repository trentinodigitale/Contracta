USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Aziende_Comunicazioni]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Aziende_Comunicazioni](
	[idMsg] [int] IDENTITY(1,1) NOT NULL,
	[idAziControllata] [int] NULL,
	[TipoComunicazione] [varchar](30) NULL,
	[DataComunicazione] [datetime] NULL,
	[Protocol] [varchar](20) NULL,
	[TipologiaAzienda] [varchar](20) NULL,
	[Esito] [varchar](20) NULL,
	[DataRilascio] [datetime] NULL,
	[NoteComunicazione] [ntext] NULL,
	[idAziDestinataria] [int] NULL,
	[idSchedaGara] [int] NULL,
	[idDoc_ContGara_For] [int] NULL,
	[ProtocolloGenerale] [varchar](50) NULL,
	[EstremiAffidamento] [nvarchar](500) NULL,
	[ValoreContratto] [float] NULL,
	[RiferimentiPrecedenti] [nvarchar](50) NULL,
	[Ufficio] [nvarchar](50) NULL,
	[OriginaleCopia] [varchar](20) NULL,
	[CarichiPendenti] [nvarchar](50) NULL,
	[Fax] [nchar](20) NULL,
	[NORM_ANTIMAFIA_DataScadenza] [datetime] NULL,
	[DURC_DataControllo] [datetime] NULL,
	[idSchedaPrecontratto] [int] NULL,
	[DURC_DataScadenza] [datetime] NULL,
	[Allegato] [nvarchar](255) NULL,
 CONSTRAINT [PK_Document_Link_Comunicazioni] PRIMARY KEY CLUSTERED 
(
	[idMsg] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
