USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempOfferteGruppi]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempOfferteGruppi](
	[mgIdProd] [int] NOT NULL,
	[mgIdMdl] [int] NULL,
	[mgProdNome] [char](101) NULL,
	[mgProdPosizione] [tinyint] NULL
) ON [PRIMARY]
GO
