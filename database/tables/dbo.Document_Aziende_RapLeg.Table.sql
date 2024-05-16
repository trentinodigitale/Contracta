USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Aziende_RapLeg]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Aziende_RapLeg](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[NomeRapLeg] [varchar](255) NULL,
	[CognomeRapLeg] [varchar](255) NULL,
	[TelefonoRapLeg] [varchar](20) NULL,
	[EmailRapLeg] [varchar](50) NULL,
	[RuoloRapLeg] [varchar](30) NULL,
	[LocalitaRapLeg] [varchar](20) NULL,
	[ProvinciaRapLeg] [varchar](20) NULL,
	[DataRapLeg] [datetime] NULL,
	[CellulareRapLeg] [varchar](20) NULL,
	[isOld] [int] NULL,
	[idAziRapLeg] [int] NULL,
	[CFRapLeg] [varchar](20) NULL,
	[ResidenzaRapLeg] [varchar](70) NULL,
	[Situazione] [varchar](50) NULL,
	[DataRiferimento] [datetime] NULL,
	[LinguaAll] [varchar](10) NULL,
	[ReferenteEMail] [varchar](50) NULL,
	[NomeUtente] [nvarchar](200) NULL,
 CONSTRAINT [PK_Document_Aziende_RapLeg] PRIMARY KEY CLUSTERED 
(
	[idRow] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Aziende_RapLeg] ADD  CONSTRAINT [DF_Document_Aziende_RapLeg_isOld]  DEFAULT (0) FOR [isOld]
GO
