USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_SIGN_ATTACH_INFO]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_SIGN_ATTACH_INFO](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ATT_Hash] [nvarchar](250) NULL,
	[isTrustedCA] [tinyint] NULL,
	[isRevoked] [int] NULL,
	[isExpired] [tinyint] NULL,
	[isValidAlgoritm] [tinyint] NULL,
	[isValidSign] [tinyint] NULL,
	[isCertificatoSottoscrizione] [tinyint] NULL,
	[numSigners] [tinyint] NULL,
	[nomeFile] [nvarchar](250) NULL,
	[signExt] [varchar](5) NULL,
	[certificatore] [nvarchar](250) NULL,
	[codFiscFirmatario] [varchar](500) NULL,
	[firmatario] [nvarchar](250) NULL,
	[dataApposizioneFirma] [datetime] NULL,
	[scadenzaFirma] [datetime] NULL,
	[usoCertificato] [varchar](150) NULL,
	[note] [ntext] NULL,
	[attIdMsg] [int] NULL,
	[attOrderFile] [int] NULL,
	[attIdObj] [int] NULL,
	[statoFirma] [varchar](50) NULL,
	[objCertificato] [image] NULL,
	[idAzi] [int] NULL,
	[algoritmo] [varchar](50) NULL,
	[dataVerifica] [datetime] NULL,
	[VerificaCF] [int] NULL,
	[tentativiTestRevoca] [int] NULL,
	[CountryName] [varchar](500) NULL,
	[subjectSerialNumber] [varchar](500) NULL,
	[certificateSerialNumber] [varchar](100) NULL,
	[HASH_PDF_FIRMA] [nvarchar](1000) NULL,
	[CF_ATTESO] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_SIGN_ATTACH_INFO] ADD  CONSTRAINT [DF_CTL_SIGN_ATTACH_INFO_dataVerifica]  DEFAULT (getdate()) FOR [dataVerifica]
GO
ALTER TABLE [dbo].[CTL_SIGN_ATTACH_INFO] ADD  CONSTRAINT [DF_CTL_SIGN_ATTACH_INFO_VerificaCF]  DEFAULT (0) FOR [VerificaCF]
GO
ALTER TABLE [dbo].[CTL_SIGN_ATTACH_INFO] ADD  CONSTRAINT [DF_CTL_SIGN_ATTACH_INFO_tentativiTestRevoca]  DEFAULT (0) FOR [tentativiTestRevoca]
GO
