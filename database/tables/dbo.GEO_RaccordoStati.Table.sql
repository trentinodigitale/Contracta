USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[GEO_RaccordoStati]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GEO_RaccordoStati](
	[CodContinente] [nvarchar](4000) NULL,
	[CodArea] [nvarchar](4000) NULL,
	[CodStato] [nvarchar](4000) NULL,
	[ISO_3166_1_2_LetterCode] [nvarchar](4000) NULL,
	[ISO_3166_1_3_LetterCode] [nvarchar](4000) NULL,
	[unioneeuropea] [nvarchar](4000) NULL,
	[commonname] [nvarchar](4000) NULL,
	[NUTS] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
