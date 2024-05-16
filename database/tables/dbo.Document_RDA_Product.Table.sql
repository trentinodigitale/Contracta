USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_RDA_Product]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_RDA_Product](
	[RDP_idRow] [int] IDENTITY(1,1) NOT NULL,
	[RDP_RDA_ID] [int] NULL,
	[RDP_VDS] [nvarchar](20) NULL,
	[RDP_Merceologia] [nvarchar](20) NULL,
	[RDP_Progetto] [nvarchar](40) NULL,
	[RDP_Fornitore] [nvarchar](20) NULL,
	[RDP_CodArtProd] [nvarchar](30) NULL,
	[RDP_Commessa] [int] NULL,
	[RDP_Importo] [float] NULL,
	[RDP_Qt] [float] NULL,
	[RDP_DataPrevCons] [datetime] NULL,
	[RDP_Desc] [nvarchar](255) NULL,
	[RDP_Allegato] [nvarchar](200) NULL,
	[RDP_TiketBudget] [int] NULL,
	[RDP_InBudget] [nvarchar](20) NULL,
	[RDP_ResidualBudget] [float] NULL,
	[RDP_TipoInvestimento] [nvarchar](20) NULL,
	[RDP_UMNonCod] [nvarchar](20) NULL,
	[RDP_Stato] [nvarchar](20) NULL,
	[RDP_cpi] [varchar](20) NULL,
	[RDP_rprot] [varchar](20) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_RDA_Product] ADD  CONSTRAINT [DF_Document_RDA_Product_RDP_Commessa]  DEFAULT (0) FOR [RDP_Commessa]
GO
ALTER TABLE [dbo].[Document_RDA_Product] ADD  CONSTRAINT [DF_Document_RDA_Product_RDP_Allegato]  DEFAULT ('') FOR [RDP_Allegato]
GO
ALTER TABLE [dbo].[Document_RDA_Product] ADD  CONSTRAINT [DF_Document_RDA_Product_RDA_ResidualBudget]  DEFAULT (0) FOR [RDP_ResidualBudget]
GO
