USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Verbale_PDA]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Verbale_PDA](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NULL,
	[NUMRIGA_EVALUATE] [varchar](50) NOT NULL,
	[IdMsg] [varchar](50) NOT NULL,
	[RAGSOC] [varchar](500) NOT NULL,
	[StatoPDA] [varchar](50) NOT NULL,
	[historymotivation] [ntext] NULL,
	[TechnicalScore] [varchar](50) NULL,
	[EconomicScore] [varchar](50) NULL,
	[TotalScore] [varchar](50) NULL,
	[ProtocolloOfferta] [varchar](50) NULL,
	[ReceivedDataMsg] [varchar](50) NULL,
	[Ribasso] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
