USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_RisultatoDiGara_Row]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_RisultatoDiGara_Row](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[Precisazione] [nvarchar](max) NULL,
	[Allegato] [nvarchar](255) NULL,
	[Versione] [smallint] NULL,
	[DataIns] [datetime] NULL,
	[DescrizioneVer] [varchar](100) NULL,
	[Idpfu] [int] NULL,
	[TipoDocumentoEsito] [nvarchar](500) NULL,
	[Protocollo] [varchar](50) NULL,
	[Deleted] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_RisultatoDiGara_Row] ADD  CONSTRAINT [DF_DOCUMENT_RISULTATODIGARA_ROW_DataIns]  DEFAULT (getdate()) FOR [DataIns]
GO
