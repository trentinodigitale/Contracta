USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MessaggiUtenti]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MessaggiUtenti](
	[muIdMsg] [int] NOT NULL,
	[muIdPfuMitt] [int] NULL,
	[muIdPfuDest] [int] NULL,
	[muIdAziMitt] [int] NULL,
	[muIdAziDest] [int] NULL,
	[muIdMpMitt] [int] NOT NULL,
	[muIdMpDest] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessaggiUtenti]  WITH CHECK ADD  CONSTRAINT [FK_MessaggiUtenti_Aziende] FOREIGN KEY([muIdAziMitt])
REFERENCES [dbo].[Aziende] ([IdAzi])
GO
ALTER TABLE [dbo].[MessaggiUtenti] CHECK CONSTRAINT [FK_MessaggiUtenti_Aziende]
GO
ALTER TABLE [dbo].[MessaggiUtenti]  WITH CHECK ADD  CONSTRAINT [FK_MessaggiUtenti_Messaggi] FOREIGN KEY([muIdMsg])
REFERENCES [dbo].[Messaggi] ([IdMsg])
GO
ALTER TABLE [dbo].[MessaggiUtenti] CHECK CONSTRAINT [FK_MessaggiUtenti_Messaggi]
GO
ALTER TABLE [dbo].[MessaggiUtenti]  WITH CHECK ADD  CONSTRAINT [FK_MessaggiUtenti_ProfiliUtente] FOREIGN KEY([muIdPfuMitt])
REFERENCES [dbo].[ProfiliUtente] ([IdPfu])
GO
ALTER TABLE [dbo].[MessaggiUtenti] CHECK CONSTRAINT [FK_MessaggiUtenti_ProfiliUtente]
GO
ALTER TABLE [dbo].[MessaggiUtenti]  WITH CHECK ADD  CONSTRAINT [FK_MessaggiUtenti_ProfiliUtente1] FOREIGN KEY([muIdPfuDest])
REFERENCES [dbo].[ProfiliUtente] ([IdPfu])
GO
ALTER TABLE [dbo].[MessaggiUtenti] CHECK CONSTRAINT [FK_MessaggiUtenti_ProfiliUtente1]
GO
