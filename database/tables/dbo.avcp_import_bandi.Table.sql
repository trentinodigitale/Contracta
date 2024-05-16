USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[avcp_import_bandi]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[avcp_import_bandi](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[codiceEstrazione] [varchar](100) NULL,
	[idMsg] [int] NOT NULL,
	[tipodoc] [varchar](250) NULL,
	[statoFunzionale] [varchar](250) NULL,
	[deleted] [int] NULL,
	[JumpCheck] [varchar](250) NULL,
	[data] [datetime] NULL,
	[PrevDoc] [int] NULL,
	[Fascicolo] [varchar](250) NULL,
	[Versione] [int] NULL,
	[LinkedDoc] [int] NULL,
	[Oggetto] [nvarchar](1000) NULL,
	[Note] [varchar](250) NULL,
	[Anno] [int] NULL,
	[Cig] [varchar](250) NULL,
	[CFprop] [varchar](250) NULL,
	[Denominazione] [varchar](1000) NULL,
	[Scelta_contraente] [varchar](250) NULL,
	[ImportoAggiudicazione] [float] NULL,
	[DataInizio] [datetime] NULL,
	[Datafine] [datetime] NULL,
	[ImportoSommeLiquidate] [float] NULL,
	[TipoBando] [int] NULL,
	[iddoc] [varchar](50) NULL,
	[AziendaMittente] [int] NULL,
	[DtPubblicazione] [datetime] NULL,
	[TipoProcedura] [varchar](15) NULL,
	[iSubType] [int] NULL,
	[origine] [varchar](15) NULL,
	[CigAusiliare] [varchar](500) NULL,
	[divisioneInLotti] [varchar](2) NULL,
	[TipoDocBando] [varchar](200) NULL,
	[CigOriginale] [varchar](250) NULL,
	[pesoGara] [int] NULL,
	[importato] [tinyint] NULL,
	[idPfuInCharge] [int] NULL,
	[idAziEnteImport] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[avcp_import_bandi] ADD  DEFAULT ((1)) FOR [pesoGara]
GO
ALTER TABLE [dbo].[avcp_import_bandi] ADD  DEFAULT ((0)) FOR [importato]
GO
