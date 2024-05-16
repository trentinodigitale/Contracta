USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Pda_Ricezione_Campioni]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Pda_Ricezione_Campioni](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[NumeroLotto] [varchar](50) NULL,
	[CIG] [nvarchar](50) NULL,
	[Descrizione] [nvarchar](max) NULL,
	[CampioneRicevuto] [varchar](20) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
