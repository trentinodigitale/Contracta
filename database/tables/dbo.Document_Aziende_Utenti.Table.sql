USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Aziende_Utenti]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Aziende_Utenti](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[NomeUtente] [varchar](255) NULL,
	[CognomeUtente] [varchar](255) NULL,
	[TelefonoUtente] [varchar](20) NULL,
	[EmailUtente] [varchar](50) NULL,
	[RuoloUtente] [varchar](30) NULL,
	[CellulareUtente] [varchar](20) NULL,
	[idAziUtente] [int] NULL,
	[funzionalitaUtente] [varchar](500) NULL
) ON [PRIMARY]
GO
