USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[OfferteArticoli]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OfferteArticoli](
	[IdOar] [int] IDENTITY(1,1) NOT NULL,
	[oarIdOff] [int] NOT NULL,
	[oarIdArt] [int] NOT NULL,
	[oarIdProd] [int] NULL,
 CONSTRAINT [PK_OfferteArticoli] PRIMARY KEY NONCLUSTERED 
(
	[IdOar] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OfferteArticoli]  WITH CHECK ADD  CONSTRAINT [FK_OfferteArticoli_Offerte] FOREIGN KEY([oarIdOff])
REFERENCES [dbo].[Offerte] ([IdOff])
GO
ALTER TABLE [dbo].[OfferteArticoli] CHECK CONSTRAINT [FK_OfferteArticoli_Offerte]
GO
