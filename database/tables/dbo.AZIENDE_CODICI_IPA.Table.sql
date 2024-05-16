USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[AZIENDE_CODICI_IPA]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AZIENDE_CODICI_IPA](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idAzi] [int] NULL,
	[Des_OU] [varchar](500) NULL,
	[Cod_Uni_OU] [varchar](20) NULL,
	[Stato_Canale] [varchar](10) NULL,
	[DataInizioSFE] [datetime] NULL,
	[Deleted] [bit] NULL,
	[Plant] [varchar](150) NULL,
	[CentroDiCosto] [varchar](150) NULL,
	[EmailReferenteIPA] [nvarchar](1000) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AZIENDE_CODICI_IPA] ADD  CONSTRAINT [DF_AZIENDE_CODICI_IPA_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[AZIENDE_CODICI_IPA] ADD  DEFAULT ('') FOR [Plant]
GO
ALTER TABLE [dbo].[AZIENDE_CODICI_IPA] ADD  DEFAULT ('') FOR [CentroDiCosto]
GO
ALTER TABLE [dbo].[AZIENDE_CODICI_IPA] ADD  DEFAULT ('') FOR [EmailReferenteIPA]
GO
