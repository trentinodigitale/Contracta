USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Aggiudicatari_Lotto]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Aggiudicatari_Lotto](
	[IdAggiudicataria] [int] IDENTITY(1,1) NOT NULL,
	[IdRow] [int] NULL,
	[aziRagioneSociale] [nvarchar](1000) NULL,
	[aziPartitaIVA] [varchar](20) NULL,
	[aziIndirizzoLeg] [varchar](80) NULL,
	[Ruolo] [varchar](50) NULL,
	[aziLocalitaLeg] [varchar](80) NULL,
	[IdAzi] [int] NULL,
	[TipoAggiudicataria] [varchar](30) NULL
) ON [PRIMARY]
GO
