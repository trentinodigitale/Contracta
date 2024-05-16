USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_ContrattoTelematico_Row]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_ContrattoTelematico_Row](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[DescrizioneEstesa] [ntext] NULL,
	[SelRow] [varchar](1) NULL,
	[Pos] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
