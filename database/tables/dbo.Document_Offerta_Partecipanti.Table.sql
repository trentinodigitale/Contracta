USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Offerta_Partecipanti]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Offerta_Partecipanti](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[TipoRiferimento] [varchar](50) NOT NULL,
	[IdAziRiferimento] [int] NULL,
	[RagSocRiferimento] [nvarchar](400) NOT NULL,
	[IdAzi] [int] NOT NULL,
	[RagSoc] [nvarchar](400) NOT NULL,
	[CodiceFiscale] [nvarchar](50) NOT NULL,
	[IndirizzoLeg] [nvarchar](200) NULL,
	[LocalitaLeg] [nvarchar](200) NULL,
	[ProvinciaLeg] [nvarchar](200) NULL,
	[Ruolo_Impresa] [varchar](50) NULL,
	[StatoDGUE] [varchar](50) NULL,
	[AllegatoDGUE] [nvarchar](255) NULL,
	[IdDocRicDGUE] [int] NULL,
	[EsitoRiga] [varchar](max) NULL,
	[Allegato] [nvarchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Offerta_Partecipanti] ADD  CONSTRAINT [DF_Document_Offerta_Partecipanti_RagSocRiferimento]  DEFAULT ('') FOR [RagSocRiferimento]
GO
