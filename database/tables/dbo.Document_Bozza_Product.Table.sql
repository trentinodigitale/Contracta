USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Bozza_Product]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Bozza_Product](
	[IDROW] [int] IDENTITY(1,1) NOT NULL,
	[IDHeader] [int] NOT NULL,
	[KeyRiga] [varchar](10) NULL,
	[CodArt] [varchar](50) NULL,
	[Merc] [varchar](10) NULL,
	[CARDescrNonCod] [nvarchar](1400) NULL,
	[Allegato] [nvarchar](300) NULL,
	[Nota] [ntext] NULL,
	[CARQuantitaDaOrdinare] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
