USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempCambi]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempCambi](
	[tmpcCodIso] [char](3) NULL,
	[tmpcCambio] [money] NULL,
	[tmpcDataCambio] [datetime] NULL
) ON [PRIMARY]
GO
