USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MSGValoriAttributi_Float]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MSGValoriAttributi_Float](
	[IdVat] [int] NOT NULL,
	[vatValore] [float] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MSGValoriAttributi_Float]  WITH CHECK ADD  CONSTRAINT [FK_MSGValoriAttributi_Float_MSGValoriAttributi] FOREIGN KEY([IdVat])
REFERENCES [dbo].[MSGValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[MSGValoriAttributi_Float] CHECK CONSTRAINT [FK_MSGValoriAttributi_Float_MSGValoriAttributi]
GO
