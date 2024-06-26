USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_DOC_ALLEGATI]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_DOC_ALLEGATI](
	[idrow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[Descrizione] [nvarchar](max) NULL,
	[Allegato] [nvarchar](max) NULL,
	[Obbligatorio] [int] NULL,
	[AnagDoc] [nvarchar](250) NULL,
	[DataEmissione] [datetime] NULL,
	[Interno] [int] NULL,
	[Modified] [nvarchar](255) NULL,
	[NotEditable] [nvarchar](255) NULL,
	[TipoFile] [nvarchar](255) NULL,
	[DataScadenza] [datetime] NULL,
	[DSE_ID] [nvarchar](50) NULL,
	[EvidenzaPubblica] [int] NULL,
	[RichiediFirma] [int] NULL,
	[FirmeRichieste] [varchar](20) NULL,
	[AllegatoRisposta] [nvarchar](max) NULL,
	[EsitoRiga] [varchar](max) NULL,
	[TemplateAllegato] [nvarchar](1000) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_DOC_ALLEGATI] ADD  CONSTRAINT [DF_CTL_DOC_ALLEGATI_EvidenzaPubblica]  DEFAULT ((0)) FOR [EvidenzaPubblica]
GO
