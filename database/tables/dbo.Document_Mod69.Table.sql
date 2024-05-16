USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Mod69]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Mod69](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ID_Repertorio] [int] NOT NULL,
	[Ufficio] [varchar](100) NULL,
	[Foglio] [varchar](50) NULL,
	[Richiedente] [varchar](100) NULL,
	[DataStipula] [datetime] NULL,
	[Rep] [int] NULL,
	[TipoContratto] [varchar](30) NULL,
	[Corrispettivo] [float] NULL,
	[danticausa] [varchar](50) NULL,
	[aventicausa] [varchar](50) NULL,
	[StatoGara] [varchar](20) NULL
) ON [PRIMARY]
GO
