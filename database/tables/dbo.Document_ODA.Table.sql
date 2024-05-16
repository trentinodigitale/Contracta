USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_ODA]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_ODA](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[TotalEURO] [float] NULL,
	[RDA_FirstApprover] [varchar](20) NULL,
	[Emergenza] [int] NULL,
	[Allegato] [nvarchar](255) NULL,
	[NumeroFattura] [nvarchar](20) NULL,
	[J_DataConsegna] [int] NULL,
	[IVA] [int] NULL,
	[ImpegnoSpesa] [nvarchar](200) NULL,
	[TotalIva] [float] NULL,
	[ReferenteConsegna] [nvarchar](50) NULL,
	[ReferenteIndirizzo] [nvarchar](50) NULL,
	[ReferenteTelefono] [nvarchar](50) NULL,
	[ReferenteEMail] [nvarchar](50) NULL,
	[ReferenteRitiro] [nvarchar](50) NULL,
	[IndirizzoRitiro] [nvarchar](50) NULL,
	[TelefonoRitiro] [nvarchar](50) NULL,
	[Id_Convenzione] [int] NULL,
	[RitiroEMail] [varchar](100) NULL,
	[RefOrd] [varchar](100) NULL,
	[RefOrdInd] [varchar](200) NULL,
	[RefOrdTel] [varchar](20) NULL,
	[RefOrdEMail] [varchar](100) NULL,
	[RDP_DataPrevCons] [datetime] NULL,
	[TipoOrdine] [nchar](1) NULL,
	[NoMail] [char](1) NULL,
	[AllegatoConsegna] [nvarchar](255) NULL,
	[TipoImporto] [varchar](100) NULL,
	[UserRUP] [int] NULL,
	[NotEditable] [varchar](500) NULL,
	[ReferenteStato] [nvarchar](500) NULL,
	[ReferenteProvincia] [nvarchar](500) NULL,
	[ReferenteLocalita] [nvarchar](500) NULL,
	[ReferenteCap] [nvarchar](50) NULL,
	[FatturazioneStato] [nvarchar](500) NULL,
	[FatturazioneProvincia] [nvarchar](500) NULL,
	[FatturazioneLocalita] [nvarchar](500) NULL,
	[FatturazioneCap] [nvarchar](50) NULL,
	[ReferenteStato2] [nvarchar](100) NULL,
	[ReferenteProvincia2] [nvarchar](100) NULL,
	[ReferenteLocalita2] [nvarchar](100) NULL,
	[FattuarzioneStato2] [nvarchar](100) NULL,
	[FatturazioneProvincia2] [nvarchar](100) NULL,
	[FatturazioneLocalita2] [nvarchar](100) NULL,
	[DataStipulaConvenzione] [datetime] NULL,
	[CIG] [varchar](50) NULL,
	[TotaleValoreAccessorio] [float] NULL,
	[EsistonoIntegrazioni] [char](1) NULL,
	[IdDocIntegrato] [int] NULL,
	[NumeroMesi] [int] NULL,
	[CodiceIPA] [varchar](50) NULL,
	[TotaleEroso] [float] NULL,
	[TotalIvaEroso] [float] NULL,
	[IdDocRidotto] [int] NULL,
	[CIG_MADRE] [nvarchar](50) NULL,
	[RichiestaCigSimog] [varchar](2) NULL,
	[idpfuRup] [varchar](50) NULL,
	[Obbligo_Cig_Derivato] [varchar](10) NULL,
	[Motivazione_ObbligoCigDerivato] [ntext] NULL,
	[EsitoControlli] [nvarchar](max) NULL,
	[CUP] [varchar](max) NULL,
	[ValoreIva] [float] NULL,
	[Appalto_PNRR] [varchar](10) NULL,
	[Appalto_PNC] [varchar](10) NULL,
	[Motivazione_Appalto_PNRR] [text] NULL,
	[Motivazione_Appalto_PNC] [text] NULL,
	[TipoAppaltoGara] [varchar](50) NULL,
	[COD_LUOGO_ISTAT] [varchar](1000) NULL,
	[DESC_LUOGO_ISTAT] [nvarchar](2000) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_ODA] ADD  DEFAULT ('') FOR [EsitoControlli]
GO
ALTER TABLE [dbo].[Document_ODA] ADD  CONSTRAINT [DF_CUP]  DEFAULT ('') FOR [CUP]
GO
