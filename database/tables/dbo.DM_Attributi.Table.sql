USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[DM_Attributi]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DM_Attributi](
	[idApp] [tinyint] NULL,
	[lnk] [int] NOT NULL,
	[idVat] [int] NOT NULL,
	[vatiddzt] [int] NULL,
	[vatidUMS] [int] NULL,
	[vatidUMSDscNome] [int] NULL,
	[vatidUMSDscSimbolo] [int] NULL,
	[dztNome] [varchar](50) NULL,
	[dztMultiValue] [bit] NULL,
	[dztIdTid] [smallint] NULL,
	[vatValore_FT] [nvarchar](3000) NULL,
	[vatValore_FV] [nvarchar](3000) NULL,
	[isDsccsx] [tinyint] NULL,
	[vatTipoMem] [tinyint] NULL,
 CONSTRAINT [PK_DM_Attributi] PRIMARY KEY CLUSTERED 
(
	[idVat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
