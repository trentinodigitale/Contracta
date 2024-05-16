USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Config_FascicoloGara]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Config_FascicoloGara](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[PercorsoDiRete] [nvarchar](max) NOT NULL,
	[Soglia] [int] NULL,
	[EMAIL] [nvarchar](1000) NOT NULL,
	[NumGiorni] [int] NULL,
	[OrganizzazioneFile] [varchar](10) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
