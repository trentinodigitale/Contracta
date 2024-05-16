USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MSGValoriAttributi_Datetime]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MSGValoriAttributi_Datetime](
	[IdVat] [int] NOT NULL,
	[vatValore] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MSGValoriAttributi_Datetime]  WITH CHECK ADD  CONSTRAINT [FK_MSGValoriAttributi_Datetime_MSGValoriAttributi] FOREIGN KEY([IdVat])
REFERENCES [dbo].[MSGValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[MSGValoriAttributi_Datetime] CHECK CONSTRAINT [FK_MSGValoriAttributi_Datetime_MSGValoriAttributi]
GO
