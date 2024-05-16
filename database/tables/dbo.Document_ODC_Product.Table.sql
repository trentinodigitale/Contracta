USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_ODC_Product]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_ODC_Product](
	[RDP_idRow] [int] IDENTITY(1,1) NOT NULL,
	[RDP_RDA_ID] [int] NULL,
	[RDP_VDS] [nvarchar](20) NULL,
	[RDP_Merceologia] [nvarchar](20) NULL,
	[RDP_Progetto] [nvarchar](180) NULL,
	[RDP_Fornitore] [nvarchar](80) NULL,
	[RDP_CodArtProd] [nvarchar](300) NULL,
	[RDP_Commessa] [nvarchar](20) NULL,
	[RDP_Importo] [float] NULL,
	[RDP_Qt] [float] NULL,
	[RDP_DataPrevCons] [datetime] NULL,
	[RDP_Desc] [nvarchar](4000) NULL,
	[RDP_Allegato] [nvarchar](200) NULL,
	[RDP_TiketBudget] [int] NULL,
	[RDP_InBudget] [nvarchar](20) NULL,
	[RDP_ResidualBudget] [float] NULL,
	[RDP_TipoInvestimento] [nvarchar](20) NULL,
	[RDP_UMNonCod] [nvarchar](20) NULL,
	[RDP_Stato] [nvarchar](20) NULL,
	[RDP_NotEditable] [varchar](255) NULL,
	[RDP_cpi] [varchar](20) NULL,
	[RDP_rprot] [varchar](20) NULL,
	[RDP_DescCod] [nvarchar](255) NULL,
	[RDP_BDD_ID] [int] NULL,
	[ValEuroDtCons] [float] NULL,
	[ValEuroDtConsMd] [int] NULL,
	[ValCambioAziDtCons] [float] NULL,
	[ValCambioAziDtConsMd] [int] NULL,
	[RDA_SOCRic] [nvarchar](10) NULL,
	[RDA_PlantRic] [nvarchar](50) NULL,
	[Marca] [nvarchar](50) NULL,
	[QtMin] [float] NULL,
	[Id_Convenzione] [nvarchar](50) NULL,
	[Nota] [text] NULL,
	[PercSconto] [float] NULL,
	[CoefCorr] [float] NULL,
	[CostoComplessivo] [float] NULL,
	[DataUtilizzo] [datetime] NULL,
	[Id_Product] [int] NULL,
	[ImportoCompenso] [float] NULL,
	[NonEditabili] [varchar](500) NULL,
	[QtMax] [float] NULL,
	[UnitMis] [nvarchar](250) NULL,
	[IVA] [float] NULL,
	[TipoProdotto] [varchar](200) NULL,
	[ToDelete] [int] NULL,
	[QTDisp] [float] NULL,
	[Evidenzia] [varchar](500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_ODC_Product] ADD  CONSTRAINT [DF__Document___RDP_C__544DA10D]  DEFAULT (0) FOR [RDP_Commessa]
GO
ALTER TABLE [dbo].[Document_ODC_Product] ADD  CONSTRAINT [DF__Document___RDP_A__5541C546]  DEFAULT ('') FOR [RDP_Allegato]
GO
ALTER TABLE [dbo].[Document_ODC_Product] ADD  CONSTRAINT [DF__Document___RDP_R__5635E97F]  DEFAULT (0) FOR [RDP_ResidualBudget]
GO
ALTER TABLE [dbo].[Document_ODC_Product] ADD  CONSTRAINT [DF__Document___RDP_T__572A0DB8]  DEFAULT ('') FOR [RDP_TipoInvestimento]
GO
ALTER TABLE [dbo].[Document_ODC_Product] ADD  CONSTRAINT [DF__Document___ValEu__581E31F1]  DEFAULT (0) FOR [ValEuroDtConsMd]
GO
ALTER TABLE [dbo].[Document_ODC_Product] ADD  CONSTRAINT [DF__Document___ValCa__5912562A]  DEFAULT (0) FOR [ValCambioAziDtConsMd]
GO
ALTER TABLE [dbo].[Document_ODC_Product] ADD  CONSTRAINT [DF__Document___RDA_S__5A067A63]  DEFAULT ('') FOR [RDA_SOCRic]
GO
ALTER TABLE [dbo].[Document_ODC_Product] ADD  CONSTRAINT [DF__Document___RDA_P__5AFA9E9C]  DEFAULT ('') FOR [RDA_PlantRic]
GO
ALTER TABLE [dbo].[Document_ODC_Product] ADD  CONSTRAINT [DF_Document_ODC_Product_ImportoCompenso]  DEFAULT (0) FOR [ImportoCompenso]
GO
