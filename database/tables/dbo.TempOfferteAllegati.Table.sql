USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempOfferteAllegati]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempOfferteAllegati](
	[oagIdOff] [int] NOT NULL,
	[oagNome] [nvarchar](20) NOT NULL,
	[oagAllegato] [image] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
