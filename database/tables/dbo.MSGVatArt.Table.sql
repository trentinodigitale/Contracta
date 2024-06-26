USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MSGVatArt]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MSGVatArt](
	[IdVat] [int] NOT NULL,
	[IdMsg] [int] NOT NULL,
	[IdArt] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MSGVatArt]  WITH CHECK ADD  CONSTRAINT [FK_MSGVatArt_Messaggi] FOREIGN KEY([IdMsg])
REFERENCES [dbo].[Messaggi] ([IdMsg])
GO
ALTER TABLE [dbo].[MSGVatArt] CHECK CONSTRAINT [FK_MSGVatArt_Messaggi]
GO
ALTER TABLE [dbo].[MSGVatArt]  WITH CHECK ADD  CONSTRAINT [FK_MSGVatArt_MSGValoriAttributi] FOREIGN KEY([IdVat])
REFERENCES [dbo].[MSGValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[MSGVatArt] CHECK CONSTRAINT [FK_MSGVatArt_MSGValoriAttributi]
GO
