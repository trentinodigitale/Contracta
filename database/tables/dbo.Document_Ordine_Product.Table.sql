USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Ordine_Product]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Ordine_Product](
	[IDROW] [int] IDENTITY(1,1) NOT NULL,
	[IDHeader] [int] NOT NULL,
	[KeyRiga] [varchar](10) NULL,
	[CodArt] [varchar](300) NULL,
	[SediDest] [varchar](255) NULL,
	[CentroDiCosto] [varchar](10) NULL,
	[VDS] [varchar](10) NULL,
	[Merc] [varchar](10) NULL,
	[KeyProgetto] [varchar](500) NULL,
	[KeyFornitore] [varchar](10) NULL,
	[IdAziRic] [int] NULL,
	[PlantRic] [varchar](255) NULL,
	[CentroDiCostoNC] [varchar](10) NULL,
	[KeyTipoInvestimento] [varchar](50) NULL,
	[Ticket] [int] NULL,
	[CARDescrNonCod] [nvarchar](4000) NULL,
	[ProtocolRDA] [varchar](50) NULL,
	[UM] [varchar](5) NULL,
	[CARCodiceLavoro] [varchar](10) NULL,
	[CARCodOperFase] [varchar](10) NULL,
	[CARCommessa] [varchar](20) NULL,
	[CARDataConsegnaProdotto] [datetime] NULL,
	[CAREsponenteModifica] [varchar](20) NULL,
	[CARFabbMat] [varchar](20) NULL,
	[CARFase] [varchar](10) NULL,
	[CARLottiMinimi] [float] NULL,
	[CARNotaArt] [nvarchar](255) NULL,
	[CARPercMat] [varchar](10) NULL,
	[CARPercTrasf] [varchar](10) NULL,
	[CARPercTrattTerm] [varchar](10) NULL,
	[CARPeso] [float] NULL,
	[CARQTAnnua] [float] NULL,
	[CARQuantitaDaOrdinare] [float] NULL,
	[CARRifPrezzo] [float] NULL,
	[CARTTConsegnaCamp] [varchar](20) NULL,
	[CARTTFornReg] [varchar](20) NULL,
	[CARUnitMisNonCod] [varchar](20) NULL,
	[CARUtilizzo] [varchar](10) NULL,
	[PrzUnOfferta] [float] NULL,
	[CPI] [varchar](20) NULL,
	[RPROT] [varchar](20) NULL,
	[CARScontoDett] [float] NULL,
	[CarValGenerico] [varchar](20) NULL,
	[CARResaGenerico] [varchar](20) NULL,
	[CARSpedizioniGenerico] [varchar](20) NULL,
	[CarCondPagGenerico] [varchar](20) NULL,
	[CARImballiGenerico] [varchar](20) NULL,
	[CARDataPartCL] [datetime] NULL,
	[CARDataConsForn] [datetime] NULL,
	[CARCODFORNCL] [varchar](10) NULL,
	[ValEuroDtCons] [float] NULL,
	[ValEuroDtConsMd] [int] NULL,
	[ValCambioAziDtCons] [float] NULL,
	[ValCambioAziDtConsMd] [int] NULL,
	[CentroDiCostoOldRic] [varchar](50) NULL,
	[Allegato] [nvarchar](255) NULL,
	[QtMin] [float] NULL,
	[Nota] [text] NULL,
	[PercSconto] [float] NULL,
	[CoefCorr] [float] NULL,
	[CostoComplessivo] [float] NULL,
	[DataUtilizzo] [datetime] NULL,
	[Id_Product] [int] NULL,
	[ImportoCompenso] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Ordine_Product] ADD  CONSTRAINT [DF_document_ordine_product_ValEuroDtConsMd_1]  DEFAULT (0) FOR [ValEuroDtConsMd]
GO
ALTER TABLE [dbo].[Document_Ordine_Product] ADD  CONSTRAINT [DF_document_ordine_product_ValCambioAziDtConsMd_1]  DEFAULT (0) FOR [ValCambioAziDtConsMd]
GO
ALTER TABLE [dbo].[Document_Ordine_Product] ADD  CONSTRAINT [DF_document_ordine_product_ImportoCompenso]  DEFAULT (0) FOR [ImportoCompenso]
GO
