USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[OfferteAllegati]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OfferteAllegati](
	[oagIdOff] [int] NOT NULL,
	[oagNome] [nvarchar](20) NOT NULL,
	[oagAllegato] [image] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[OfferteAllegati]  WITH CHECK ADD  CONSTRAINT [FK_OfferteAllegati_Offerte] FOREIGN KEY([oagIdOff])
REFERENCES [dbo].[Offerte] ([IdOff])
GO
ALTER TABLE [dbo].[OfferteAllegati] CHECK CONSTRAINT [FK_OfferteAllegati_Offerte]
GO
