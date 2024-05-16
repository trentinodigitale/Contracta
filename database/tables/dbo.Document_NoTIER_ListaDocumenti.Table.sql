USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_NoTIER_ListaDocumenti]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_NoTIER_ListaDocumenti](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idazi] [int] NULL,
	[idpfu] [int] NULL,
	[data] [datetime] NULL,
	[URN] [varchar](500) NULL,
	[DATARICEZIONENOTIER] [varchar](30) NULL,
	[STATOGIACENZA] [varchar](500) NULL,
	[CHIAVE_CODICEFISCALEMITTENTE] [varchar](50) NULL,
	[CHIAVE_ANNO] [varchar](10) NULL,
	[CHIAVE_NUMERO] [varchar](100) NULL,
	[CHIAVE_TIPODOCUMENTO] [varchar](100) NULL,
	[URN_NO_V] [varchar](500) NULL,
	[URN_V] [varchar](500) NULL,
	[deleted] [bit] NOT NULL,
	[IDPEPPOLDESTINATARIO] [varchar](500) NULL,
	[IDPEPPOLMITTENTE] [varchar](500) NULL,
	[xmlDett] [varchar](max) NULL,
	[numRetry] [int] NULL,
	[esitoKo] [int] NULL,
	[linkedDoc] [int] NULL,
	[RagioneSocialeMittente] [nvarchar](1000) NULL,
	[IDNOTIER_FLUSSO] [nvarchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_NoTIER_ListaDocumenti] ADD  CONSTRAINT [DF__Document_N__data__732A254B]  DEFAULT (getdate()) FOR [data]
GO
ALTER TABLE [dbo].[Document_NoTIER_ListaDocumenti] ADD  DEFAULT ((0)) FOR [deleted]
GO
