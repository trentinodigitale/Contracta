USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Bando_Riferimenti]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Bando_Riferimenti](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[idPfu] [int] NULL,
	[RuoloRiferimenti] [varchar](50) NULL
) ON [PRIMARY]
GO
