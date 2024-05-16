USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Aziende]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Aziende](
	[IdAzi] [int] IDENTITY(35152028,1) NOT NULL,
	[aziTs] [timestamp] NOT NULL,
	[aziLog] [char](7) NULL,
	[aziDataCreazione] [datetime] NOT NULL,
	[aziRagioneSociale] [nvarchar](1000) NULL,
	[aziRagioneSocialeNorm] [nvarchar](1000) NULL,
	[aziIdDscFormaSoc] [int] NULL,
	[aziPartitaIVA] [nvarchar](20) NULL,
	[aziE_Mail] [nvarchar](255) NULL,
	[aziAcquirente] [smallint] NOT NULL,
	[aziVenditore] [smallint] NOT NULL,
	[aziProspect] [smallint] NOT NULL,
	[aziIndirizzoLeg] [nvarchar](80) NULL,
	[aziIndirizzoOp] [nvarchar](80) NULL,
	[aziLocalitaLeg] [nvarchar](80) NULL,
	[aziLocalitaOp] [nvarchar](80) NULL,
	[aziProvinciaLeg] [nvarchar](80) NULL,
	[aziProvinciaOp] [nvarchar](20) NULL,
	[aziStatoLeg] [nvarchar](80) NULL,
	[aziStatoOp] [nvarchar](20) NULL,
	[aziCAPLeg] [nvarchar](8) NULL,
	[aziCapOp] [nvarchar](8) NULL,
	[aziPrefisso] [nvarchar](10) NULL,
	[aziTelefono1] [nvarchar](50) NULL,
	[aziTelefono2] [nvarchar](50) NULL,
	[aziFAX] [nvarchar](50) NULL,
	[aziLogo] [image] NULL,
	[aziIdDscDescrizione] [int] NULL,
	[aziProssimoProtRdo] [smallint] NOT NULL,
	[aziProssimoProtOff] [smallint] NOT NULL,
	[aziGphValueOper] [int] NULL,
	[aziDeleted] [tinyint] NOT NULL,
	[aziDBNumber] [int] NULL,
	[aziAtvAtecord] [varchar](20) NULL,
	[aziSitoWeb] [nvarchar](300) NULL,
	[aziCodEurocredit] [int] NULL,
	[aziProfili] [varchar](20) NULL,
	[aziProvinciaLeg2] [varchar](50) NULL,
	[aziStatoLeg2] [varchar](50) NULL,
	[aziFunzionalita] [varchar](400) NOT NULL,
	[CertificatoIscrAtt] [nvarchar](255) NULL,
	[TipoDiAmministr] [nvarchar](5) NULL,
	[aziLocalitaLeg2] [nvarchar](80) NULL,
	[daValutare] [int] NULL,
	[aziNumeroCivico] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Aziende] ADD  CONSTRAINT [DF_Aziende_aziDataCreazione]  DEFAULT (getdate()) FOR [aziDataCreazione]
GO
ALTER TABLE [dbo].[Aziende] ADD  CONSTRAINT [DF_Aziende_aziIdDscFormaSoc]  DEFAULT ((23903)) FOR [aziIdDscFormaSoc]
GO
ALTER TABLE [dbo].[Aziende] ADD  CONSTRAINT [DF_Aziende_aziIsBuyer]  DEFAULT ((0)) FOR [aziAcquirente]
GO
ALTER TABLE [dbo].[Aziende] ADD  CONSTRAINT [DF_Aziende_aziIdSeller]  DEFAULT ((0)) FOR [aziVenditore]
GO
ALTER TABLE [dbo].[Aziende] ADD  CONSTRAINT [DF_Aziende_aziProspect]  DEFAULT ((0)) FOR [aziProspect]
GO
ALTER TABLE [dbo].[Aziende] ADD  CONSTRAINT [DF_Aziende_aziProssimoProtRdo_1]  DEFAULT ((1)) FOR [aziProssimoProtRdo]
GO
ALTER TABLE [dbo].[Aziende] ADD  CONSTRAINT [DF_Aziende_aziProssimoProtOff_1]  DEFAULT ((1)) FOR [aziProssimoProtOff]
GO
ALTER TABLE [dbo].[Aziende] ADD  CONSTRAINT [DF_Aziende_aziGphValueOper]  DEFAULT ((0)) FOR [aziGphValueOper]
GO
ALTER TABLE [dbo].[Aziende] ADD  CONSTRAINT [DF_Aziende_aziDeleted]  DEFAULT ((0)) FOR [aziDeleted]
GO
ALTER TABLE [dbo].[Aziende] ADD  CONSTRAINT [DF_Aziende_aziAtvAtecord]  DEFAULT ('196') FOR [aziAtvAtecord]
GO
ALTER TABLE [dbo].[Aziende] ADD  CONSTRAINT [DF_Aziende_aziFunzionalita]  DEFAULT ('0010000000000001111110000000000001111111000000100000000000000111111000000001111001110110011100101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000001000100001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000') FOR [aziFunzionalita]
GO
ALTER TABLE [dbo].[Aziende] ADD  CONSTRAINT [DF_Aziende_daValutare]  DEFAULT ((0)) FOR [daValutare]
GO
