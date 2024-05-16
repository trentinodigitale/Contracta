USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MSGValoriAttributi_Descrizioni]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MSGValoriAttributi_Descrizioni](
	[IdVat] [int] NOT NULL,
	[vatIdDsc] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MSGValoriAttributi_Descrizioni]  WITH CHECK ADD  CONSTRAINT [FK_MSGValoriAttributi_Descrizioni_MSGValoriAttributi] FOREIGN KEY([IdVat])
REFERENCES [dbo].[MSGValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[MSGValoriAttributi_Descrizioni] CHECK CONSTRAINT [FK_MSGValoriAttributi_Descrizioni_MSGValoriAttributi]
GO
