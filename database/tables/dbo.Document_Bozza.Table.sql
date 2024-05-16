USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Bozza]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Bozza](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdMsg] [int] NULL,
	[iType] [smallint] NULL,
	[iSubType] [smallint] NULL,
	[DataIns] [datetime] NULL,
	[NumOrd] [varchar](50) NULL,
	[Protocol] [varchar](50) NULL,
	[ProtocolOrdine] [varchar](50) NULL,
	[StatoBozza] [varchar](20) NULL,
	[Plant] [varchar](255) NULL,
	[Name] [nvarchar](255) NULL,
	[IdDestinatario] [int] NULL,
	[IdAziDest] [int] NULL,
	[IdMittente] [int] NULL,
	[Nota] [ntext] NULL,
	[Deleted] [tinyint] NULL,
	[ODC_PEG] [varchar](50) NULL,
	[Capitolo] [varchar](20) NULL,
	[NumeroConvenzione] [varchar](20) NULL,
	[Id_Convenzione] [int] NULL,
	[Id_Ordine] [int] NULL,
	[Id_ODC] [int] NULL,
	[ImpegnoSpesa] [nvarchar](50) NULL,
	[NoteComunicazione] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Bozza] ADD  CONSTRAINT [DF_document_bozza_StatoBozza]  DEFAULT ('Saved') FOR [StatoBozza]
GO
ALTER TABLE [dbo].[Document_Bozza] ADD  CONSTRAINT [DF__document___Delet__6E2D6EA1]  DEFAULT (0) FOR [Deleted]
GO
