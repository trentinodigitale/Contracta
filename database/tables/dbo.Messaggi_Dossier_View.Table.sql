USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Messaggi_Dossier_View]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Messaggi_Dossier_View](
	[IdMsg] [int] NOT NULL,
	[Pratica] [nvarchar](100) NULL,
	[ProtocolBG] [nvarchar](100) NULL,
	[ProtocolloBando] [nvarchar](100) NULL,
	[ProtocolloOfferta] [nvarchar](100) NULL,
	[ReceivedDataMsg] [datetime] NULL
) ON [PRIMARY]
GO
