USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Modelli_Prodotti]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Modelli_Prodotti](
	[IdMdl] [int] NOT NULL,
	[MdlIdArt] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Modelli_Prodotti]  WITH CHECK ADD  CONSTRAINT [FK_Modelli_Prodotti_Articoli] FOREIGN KEY([MdlIdArt])
REFERENCES [dbo].[Articoli] ([IdArt])
GO
ALTER TABLE [dbo].[Modelli_Prodotti] CHECK CONSTRAINT [FK_Modelli_Prodotti_Articoli]
GO
