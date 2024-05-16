USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[DfVatArt]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DfVatArt](
	[IdVat] [int] NOT NULL,
	[IdArt] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DfVatArt]  WITH CHECK ADD  CONSTRAINT [FK_DfVatArt_Articoli] FOREIGN KEY([IdArt])
REFERENCES [dbo].[Articoli] ([IdArt])
GO
ALTER TABLE [dbo].[DfVatArt] CHECK CONSTRAINT [FK_DfVatArt_Articoli]
GO
ALTER TABLE [dbo].[DfVatArt]  WITH CHECK ADD  CONSTRAINT [FK_DfVatArt_ValoriAttributi] FOREIGN KEY([IdVat])
REFERENCES [dbo].[ValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[DfVatArt] CHECK CONSTRAINT [FK_DfVatArt_ValoriAttributi]
GO
