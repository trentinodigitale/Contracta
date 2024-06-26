USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Richiesta_Atti]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Richiesta_Atti](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[Nome] [text] NULL,
	[ComuneNascitaPF] [text] NULL,
	[DataNascitaPF] [datetime] NULL,
	[PAIndirizzoOp] [text] NULL,
	[Indirizzo] [text] NULL,
	[NomeRapLeg] [text] NULL,
	[SedeEdile] [text] NULL,
	[IndirizzoEdile] [text] NULL,
	[PartitaIva] [text] NULL,
	[codicefiscale] [text] NULL,
	[ControlliEffettuati] [char](1) NULL,
	[Offerta] [char](1) NULL,
	[DomandaPar] [char](1) NULL,
	[Altro] [char](1) NULL,
	[Tipo_Appalto] [nvarchar](20) NULL,
	[Motivo] [text] NULL,
	[Allegato] [nvarchar](255) NULL,
	[aziRagioneSociale] [nvarchar](1000) NULL,
	[StatoRichiestaAtti] [nvarchar](50) NULL,
	[CIG] [nvarchar](100) NULL,
	[RuoloRapLeg] [nvarchar](200) NULL,
	[CHIUSURA_RICHIESTA] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
