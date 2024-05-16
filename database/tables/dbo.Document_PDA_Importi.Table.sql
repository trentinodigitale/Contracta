USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_PDA_Importi]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_PDA_Importi](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdPdA] [varchar](10) NULL,
	[NumRiga] [varchar](10) NULL,
	[DescrImportiVari] [varchar](10) NULL,
	[UM_ImportiVari] [varchar](10) NULL,
	[ImportiVari] [varchar](10) NULL
) ON [PRIMARY]
GO
