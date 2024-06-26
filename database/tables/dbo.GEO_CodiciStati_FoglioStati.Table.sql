USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[GEO_CodiciStati_FoglioStati]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GEO_CodiciStati_FoglioStati](
	[CodContinente] [nvarchar](4000) NULL,
	[CodArea] [nvarchar](4000) NULL,
	[CodStato] [nvarchar](4000) NULL,
	[UnioneEuropea] [nvarchar](4000) NULL,
	[EuropeanUnion] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
