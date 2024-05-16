USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_RisultatoDiGara]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_RisultatoDiGara](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DataCreazione] [datetime] NULL,
	[ID_MSG_BANDO] [int] NULL,
	[Precisazione] [nvarchar](max) NULL,
	[DocumentoAllegato] [nvarchar](255) NULL,
	[Oggetto] [nvarchar](max) NULL,
	[TipoDoc_src] [varchar](50) NULL,
	[ValoreContratto] [float] NULL,
	[DataPubbEsito] [datetime] NULL,
	[CodSCP] [varchar](50) NULL,
	[UrlSCP] [varchar](300) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_RisultatoDiGara] ADD  CONSTRAINT [DF_DOCUMENT_PRECISAZIONIBANDO_DataCreazione]  DEFAULT (getdate()) FOR [DataCreazione]
GO
ALTER TABLE [dbo].[Document_RisultatoDiGara] ADD  CONSTRAINT [DF_Document_RisultatoDiGara_TipoDoc_src]  DEFAULT ('') FOR [TipoDoc_src]
GO
