USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempOfferteArticoli]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempOfferteArticoli](
	[IdOar] [int] NOT NULL,
	[oarIdOff] [int] NOT NULL,
	[oarIdArt] [int] NOT NULL,
	[oarIdProd] [int] NULL
) ON [PRIMARY]
GO
