USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Atti_Rettifica]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Atti_Rettifica](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[Eliminato] [varchar](30) NULL,
	[Descrizione] [nvarchar](max) NULL,
	[Allegato] [nvarchar](1000) NULL,
	[Descrizione_OLD] [nvarchar](max) NULL,
	[Allegato_OLD] [nvarchar](1000) NULL,
	[AnagDoc] [nvarchar](250) NULL,
	[EvidenzaPubblica] [varchar](10) NULL,
	[EvidenzaPubblica_OLD] [varchar](10) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
