USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MessaggiArticoli]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MessaggiArticoli](
	[maIdMsg] [int] NOT NULL,
	[maIdArt] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessaggiArticoli]  WITH CHECK ADD  CONSTRAINT [FK_MessaggiArticoli_Messaggi] FOREIGN KEY([maIdMsg])
REFERENCES [dbo].[Messaggi] ([IdMsg])
GO
ALTER TABLE [dbo].[MessaggiArticoli] CHECK CONSTRAINT [FK_MessaggiArticoli_Messaggi]
GO
