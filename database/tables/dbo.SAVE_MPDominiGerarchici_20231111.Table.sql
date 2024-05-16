USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[SAVE_MPDominiGerarchici_20231111]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SAVE_MPDominiGerarchici_20231111](
	[IdMpDg] [int] IDENTITY(1,1) NOT NULL,
	[mpdgIdMp] [int] NOT NULL,
	[mpdgIdDg] [int] NOT NULL,
	[mpdgTipo] [smallint] NOT NULL,
	[mpdgShowPath] [bit] NOT NULL,
	[mpdgDeleted] [bit] NOT NULL,
	[mpdgUltimaMod] [datetime] NOT NULL
) ON [PRIMARY]
GO
