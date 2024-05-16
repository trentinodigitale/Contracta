USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Elenco_Funzioni_Permessi]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Elenco_Funzioni_Permessi](
	[LFN_GroupFunction] [varchar](2000) NULL,
	[Title] [varchar](2000) NULL,
	[LFN_PosPermission] [int] NULL,
	[Path] [varchar](2000) NULL,
	[LFN_Target] [varchar](2000) NULL,
	[Attivo] [int] NOT NULL
) ON [PRIMARY]
GO
