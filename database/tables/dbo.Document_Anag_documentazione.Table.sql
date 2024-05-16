USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Anag_documentazione]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Anag_documentazione](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[AnagDoc] [varchar](20) NULL,
	[Scadenza] [char](1) NULL,
	[NumMesiVal] [int] NULL,
	[NumFrePreAlert] [int] NULL,
	[FreqPrimaria] [int] NULL,
	[FreqSecondaria] [int] NULL,
	[DestinatarioAllert] [varchar](20) NULL,
	[Albo] [char](1) NULL,
	[SoloInterno] [char](1) NULL,
	[Allegato] [nvarchar](255) NULL,
	[deleted] [int] NULL,
	[ContestoUsoDoc] [nvarchar](255) NULL,
	[AreaValutazione] [varchar](50) NULL,
	[Peso] [float] NULL,
	[Obbligatorio] [int] NULL,
	[EMAS] [varchar](5) NULL,
	[TipoValutazione] [varchar](50) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Anag_documentazione] ADD  CONSTRAINT [DF_Document_Anag_documentazione_Scadenza]  DEFAULT ('0') FOR [Scadenza]
GO
ALTER TABLE [dbo].[Document_Anag_documentazione] ADD  CONSTRAINT [DF_Document_Anag_documentazione_Albo]  DEFAULT ('0') FOR [Albo]
GO
ALTER TABLE [dbo].[Document_Anag_documentazione] ADD  CONSTRAINT [DF_Document_Anag_documentazione_SoloInterno]  DEFAULT ('0') FOR [SoloInterno]
GO
ALTER TABLE [dbo].[Document_Anag_documentazione] ADD  CONSTRAINT [DF_Document_Anag_documentazione_deleted]  DEFAULT (0) FOR [deleted]
GO
