USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MSGValoriAttributi_Keys]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MSGValoriAttributi_Keys](
	[IdVat] [int] NOT NULL,
	[vatValore] [int] NOT NULL,
	[vatValoreUp] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MSGValoriAttributi_Keys]  WITH CHECK ADD  CONSTRAINT [FK_MSGValoriAttributi_Keys_MSGValoriAttributi] FOREIGN KEY([IdVat])
REFERENCES [dbo].[MSGValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[MSGValoriAttributi_Keys] CHECK CONSTRAINT [FK_MSGValoriAttributi_Keys_MSGValoriAttributi]
GO
