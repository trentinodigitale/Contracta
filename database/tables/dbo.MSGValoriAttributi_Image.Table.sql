USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MSGValoriAttributi_Image]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MSGValoriAttributi_Image](
	[IdVat] [int] NOT NULL,
	[vatValore] [image] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[MSGValoriAttributi_Image]  WITH CHECK ADD  CONSTRAINT [FK_MSGValoriAttributi_Image_MSGValoriAttributi] FOREIGN KEY([IdVat])
REFERENCES [dbo].[MSGValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[MSGValoriAttributi_Image] CHECK CONSTRAINT [FK_MSGValoriAttributi_Image_MSGValoriAttributi]
GO
