USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Bando_Scaglioni_Valutazioni]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Bando_Scaglioni_Valutazioni](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[minPunteggio] [float] NULL,
	[maxPunteggio] [float] NULL,
	[PercMaxAssentibile] [float] NULL,
	[ImportoMaxAssentibile] [float] NULL,
	[Linea] [varchar](50) NULL,
	[Intervento] [varchar](50) NULL
) ON [PRIMARY]
GO
