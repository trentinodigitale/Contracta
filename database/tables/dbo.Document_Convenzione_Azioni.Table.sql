USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Convenzione_Azioni]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Convenzione_Azioni](
	[ID_ROW] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NULL,
	[Stato] [varchar](20) NULL,
	[Owner] [int] NULL,
	[Protocol] [nchar](10) NULL,
	[Motivazione] [ntext] NULL,
	[Total] [float] NULL,
	[DataIns] [datetime] NULL,
	[deleted] [int] NULL,
	[Azione] [nchar](10) NULL,
	[TipoEstensione] [varchar](50) NULL,
	[Vaue_Originario] [float] NULL,
	[ImportoEstensione] [float] NULL,
	[PercEstensione] [float] NULL,
	[ImportoEstensioneDigitato] [float] NULL,
	[AggiornaQuote] [varchar](10) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Convenzione_Azioni] ADD  CONSTRAINT [DF_Document_Convenzione_Azioni_Stato]  DEFAULT ('Saved') FOR [Stato]
GO
ALTER TABLE [dbo].[Document_Convenzione_Azioni] ADD  CONSTRAINT [DF_Document_Convenzione_Azioni_DataIns]  DEFAULT (getdate()) FOR [DataIns]
GO
ALTER TABLE [dbo].[Document_Convenzione_Azioni] ADD  CONSTRAINT [DF_Document_Convenzione_Azioni_deleted]  DEFAULT (0) FOR [deleted]
GO
