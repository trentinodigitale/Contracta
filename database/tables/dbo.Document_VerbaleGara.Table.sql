USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_VerbaleGara]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_VerbaleGara](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[ProceduraGara] [varchar](100) NULL,
	[CriterioAggiudicazioneGara] [varchar](100) NULL,
	[Testata] [ntext] NULL,
	[PiePagina] [ntext] NULL,
	[Testata2] [ntext] NULL,
	[Multiplo] [varchar](2) NULL,
	[IdTipoVerbale] [int] NULL,
	[TipoVerbale] [varchar](100) NULL,
	[TipoSorgente] [varchar](200) NULL,
	[CriterioFormulazioneOfferte] [varchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_VerbaleGara] ADD  CONSTRAINT [DF_Document_VerbaleGara_Testata]  DEFAULT ('') FOR [Testata]
GO
ALTER TABLE [dbo].[Document_VerbaleGara] ADD  CONSTRAINT [DF_Document_VerbaleGara_Testata2]  DEFAULT ('') FOR [Testata2]
GO
ALTER TABLE [dbo].[Document_VerbaleGara] ADD  CONSTRAINT [DF_Document_VerbaleGara_Multiplo]  DEFAULT ('si') FOR [Multiplo]
GO
ALTER TABLE [dbo].[Document_VerbaleGara] ADD  CONSTRAINT [DF_Document_VerbaleGara_TipoVerbale]  DEFAULT ('') FOR [TipoVerbale]
GO
ALTER TABLE [dbo].[Document_VerbaleGara] ADD  CONSTRAINT [DF_Document_VerbaleGara_TipologiaPDA]  DEFAULT ('1') FOR [TipoSorgente]
GO
