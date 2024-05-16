USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[DOCUMENT_BANDO_INVITI_LAVORI]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DOCUMENT_BANDO_INVITI_LAVORI](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[idAzi] [int] NULL,
	[CategoriaSOA] [varchar](4000) NULL,
	[ClassificaSOA] [varchar](4000) NULL,
	[NumInvitiVirtuali] [int] NULL,
	[NumInvitiReali] [int] NULL,
	[Iscritto] [int] NULL
) ON [PRIMARY]
GO
