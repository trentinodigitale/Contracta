USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Bando_DocumentazioneRichiesta]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Bando_DocumentazioneRichiesta](
	[idrow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[TipoInterventoDocumentazione] [varchar](50) NULL,
	[LineaDocumentazione] [varchar](50) NULL,
	[DescrizioneRichiesta] [ntext] NULL,
	[AllegatoRichiesto] [nvarchar](255) NULL,
	[Obbligatorio] [int] NULL,
	[TipoFile] [varchar](200) NULL,
	[AnagDoc] [nvarchar](250) NULL,
	[NotEditable] [nvarchar](255) NULL,
	[RichiediFirma] [int] NULL,
	[AreaValutazione] [varchar](100) NULL,
	[Punteggio] [float] NULL,
	[DataScadenza] [datetime] NULL,
	[Peso] [int] NULL,
	[AllegatoValutatore] [nvarchar](255) NULL,
	[Note] [varchar](2000) NULL,
	[TipoValutazione] [varchar](20) NULL,
	[EMAS] [varchar](5) NULL,
	[DSE_ID] [varchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
