USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_AziSortPub]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_AziSortPub](
	[idrow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[idAzi] [int] NOT NULL,
	[ordinamento] [int] NULL,
	[protocollo] [varchar](100) NULL,
	[dataInvio] [datetime] NULL,
	[idManInt] [int] NULL,
	[numeroRandom] [float] NULL
) ON [PRIMARY]
GO
