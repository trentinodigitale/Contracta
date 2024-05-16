USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_VerbaleGara_Dettagli]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_VerbaleGara_Dettagli](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NULL,
	[Pos] [smallint] NULL,
	[SelRow] [varchar](1) NULL,
	[TitoloSezione] [varchar](500) NULL,
	[DescrizioneEstesa] [ntext] NULL,
	[Edit] [varchar](1) NULL,
	[CanEdit] [varchar](1) NULL,
	[Expression] [varchar](1000) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_VerbaleGara_Dettagli] ADD  CONSTRAINT [DF_Document_VerbaleGara_Dettagli_SelRow]  DEFAULT ('1') FOR [SelRow]
GO
ALTER TABLE [dbo].[Document_VerbaleGara_Dettagli] ADD  CONSTRAINT [DF_Document_VerbaleGara_Dettagli_TitoloSezione]  DEFAULT ('') FOR [TitoloSezione]
GO
ALTER TABLE [dbo].[Document_VerbaleGara_Dettagli] ADD  CONSTRAINT [DF_Document_VerbaleGara_Dettagli_Edit]  DEFAULT ('1') FOR [Edit]
GO
ALTER TABLE [dbo].[Document_VerbaleGara_Dettagli] ADD  CONSTRAINT [DF_Document_VerbaleGara_Dettagli_CanEdit]  DEFAULT ('1') FOR [CanEdit]
GO
ALTER TABLE [dbo].[Document_VerbaleGara_Dettagli] ADD  CONSTRAINT [DF_Document_VerbaleGara_Dettagli_Exp]  DEFAULT ('') FOR [Expression]
GO
