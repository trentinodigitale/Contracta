USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[SAVE_DominiGerarchici_20231111]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SAVE_DominiGerarchici_20231111](
	[IdDg] [int] IDENTITY(1,1) NOT NULL,
	[dgTipoGerarchia] [smallint] NOT NULL,
	[dgCodiceInterno] [varchar](30) NOT NULL,
	[dgCodiceEsterno] [varchar](30) NOT NULL,
	[dgPath] [varchar](100) NOT NULL,
	[dgLivello] [smallint] NOT NULL,
	[dgFoglia] [bit] NOT NULL,
	[dgLenPathPadre] [smallint] NOT NULL,
	[dgIdDsc] [int] NOT NULL,
	[dgDeleted] [bit] NOT NULL,
	[dgUltimaMod] [datetime] NOT NULL,
	[dgCodiceRaccordo] [varchar](20) NULL
) ON [PRIMARY]
GO
