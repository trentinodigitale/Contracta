USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TAB_UTENTI_MESSAGGI]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TAB_UTENTI_MESSAGGI](
	[IdUm] [int] IDENTITY(1,1) NOT NULL,
	[umIdMsg] [int] NOT NULL,
	[umIdPfu] [int] NOT NULL,
	[umInput] [bit] NOT NULL,
	[umIsProspect] [smallint] NOT NULL,
	[umIdMsgOrigine] [int] NULL,
	[umStato] [tinyint] NOT NULL,
	[umDataLastMail] [datetime] NOT NULL,
	[umNumMail] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAB_UTENTI_MESSAGGI] ADD  CONSTRAINT [DF_TAB_UTENTI_MESSAGGI_umInput]  DEFAULT (0) FOR [umInput]
GO
ALTER TABLE [dbo].[TAB_UTENTI_MESSAGGI] ADD  CONSTRAINT [DF_TAB_UTENTI_MESSAGGI_umIsProspect]  DEFAULT (0) FOR [umIsProspect]
GO
ALTER TABLE [dbo].[TAB_UTENTI_MESSAGGI] ADD  CONSTRAINT [DF_TAB_UTENTI_MESSAGGI_umIdMsgOrigine]  DEFAULT (0) FOR [umIdMsgOrigine]
GO
ALTER TABLE [dbo].[TAB_UTENTI_MESSAGGI] ADD  CONSTRAINT [DF_TAB_UTENTI_MESSAGGI_umStato]  DEFAULT (0) FOR [umStato]
GO
ALTER TABLE [dbo].[TAB_UTENTI_MESSAGGI] ADD  CONSTRAINT [DF_TAB_UTENTI_MESSAGGI_umDataLastMail]  DEFAULT (getdate()) FOR [umDataLastMail]
GO
ALTER TABLE [dbo].[TAB_UTENTI_MESSAGGI] ADD  CONSTRAINT [DF_TAB_UTENTI_MESSAGGI_umNumMail]  DEFAULT (0) FOR [umNumMail]
GO
ALTER TABLE [dbo].[TAB_UTENTI_MESSAGGI]  WITH CHECK ADD  CONSTRAINT [FK_TAB_UTENTI_MESSAGGI_TAB_MESSAGGI] FOREIGN KEY([umIdMsg])
REFERENCES [dbo].[TAB_MESSAGGI] ([IdMsg])
GO
ALTER TABLE [dbo].[TAB_UTENTI_MESSAGGI] CHECK CONSTRAINT [FK_TAB_UTENTI_MESSAGGI_TAB_MESSAGGI]
GO
