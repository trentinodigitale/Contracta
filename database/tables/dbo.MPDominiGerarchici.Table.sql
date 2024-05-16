USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPDominiGerarchici]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPDominiGerarchici](
	[IdMpDg] [int] IDENTITY(1,1) NOT NULL,
	[mpdgIdMp] [int] NOT NULL,
	[mpdgIdDg] [int] NOT NULL,
	[mpdgTipo] [smallint] NOT NULL,
	[mpdgShowPath] [bit] NOT NULL,
	[mpdgDeleted] [bit] NOT NULL,
	[mpdgUltimaMod] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MPDominiGerarchici] ADD  CONSTRAINT [DF_MPDominiGerarchici_mpdgTipoShowPath]  DEFAULT (0) FOR [mpdgShowPath]
GO
ALTER TABLE [dbo].[MPDominiGerarchici] ADD  CONSTRAINT [DF_MPDominiGerarchici_mpatvDeleted]  DEFAULT (0) FOR [mpdgDeleted]
GO
ALTER TABLE [dbo].[MPDominiGerarchici] ADD  CONSTRAINT [DF_MPDominiGerarchici_mpatvUltimaMod]  DEFAULT (getdate()) FOR [mpdgUltimaMod]
GO
ALTER TABLE [dbo].[MPDominiGerarchici]  WITH NOCHECK ADD  CONSTRAINT [FK_MPDominiGerarchici_DominiGerarchici] FOREIGN KEY([mpdgIdDg])
REFERENCES [dbo].[DominiGerarchici] ([IdDg])
GO
ALTER TABLE [dbo].[MPDominiGerarchici] CHECK CONSTRAINT [FK_MPDominiGerarchici_DominiGerarchici]
GO
ALTER TABLE [dbo].[MPDominiGerarchici]  WITH CHECK ADD  CONSTRAINT [FK_MPDominiGerarchici_MarketPlace] FOREIGN KEY([mpdgIdMp])
REFERENCES [dbo].[MarketPlace] ([IdMp])
GO
ALTER TABLE [dbo].[MPDominiGerarchici] CHECK CONSTRAINT [FK_MPDominiGerarchici_MarketPlace]
GO
