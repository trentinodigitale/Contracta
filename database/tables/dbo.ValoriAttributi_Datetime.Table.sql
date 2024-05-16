USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ValoriAttributi_Datetime]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ValoriAttributi_Datetime](
	[IdVat] [int] NOT NULL,
	[vatValore] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ValoriAttributi_Datetime]  WITH CHECK ADD  CONSTRAINT [FK_ValoriAttributi_Datetime_ValoriAttributi] FOREIGN KEY([IdVat])
REFERENCES [dbo].[ValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[ValoriAttributi_Datetime] CHECK CONSTRAINT [FK_ValoriAttributi_Datetime_ValoriAttributi]
GO
