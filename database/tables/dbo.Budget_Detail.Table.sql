USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Budget_Detail]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Budget_Detail](
	[BDD_BDG_Periodo] [nvarchar](10) NOT NULL,
	[BDD_DataCreazione] [datetime] NOT NULL,
	[BDD_KeySOC] [nvarchar](20) NOT NULL,
	[BDD_KeyPlant] [nvarchar](30) NOT NULL,
	[BDD_KeyVDS] [nvarchar](20) NOT NULL,
	[BDD_KeyCDC] [nvarchar](20) NOT NULL,
	[BDD_KeyMerceologia] [nvarchar](20) NOT NULL,
	[BDD_KeyProgetto] [nvarchar](40) NULL,
	[BDD_KeyFornitore] [nvarchar](20) NULL,
	[BDD_KeyCodArtProd] [nvarchar](30) NULL,
	[BDD_KeySOCRic] [nvarchar](20) NULL,
	[BDD_KeyPlantRic] [nvarchar](30) NULL,
	[BDD_Commessa] [nvarchar](20) NULL,
	[BDD_Importo] [float] NULL,
	[BDD_Check] [int] NOT NULL,
	[BDD_Level] [nvarchar](20) NOT NULL,
	[BDD_id] [int] IDENTITY(1,1) NOT NULL,
	[BDD_KeyTipoInvestimento] [nvarchar](20) NULL,
	[BDD_Note] [nvarchar](1000) NULL,
	[BDG_ECONOMO] [char](1) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Budget_Detail] ADD  CONSTRAINT [DF_Budget_Detail_BDD_DataCreazione]  DEFAULT (getdate()) FOR [BDD_DataCreazione]
GO
ALTER TABLE [dbo].[Budget_Detail] ADD  CONSTRAINT [DF_Budget_Detail_BDD_KeyProgetto]  DEFAULT ('') FOR [BDD_KeyProgetto]
GO
ALTER TABLE [dbo].[Budget_Detail] ADD  CONSTRAINT [DF_Budget_Detail_BDD_KeyFornitore]  DEFAULT ('') FOR [BDD_KeyFornitore]
GO
ALTER TABLE [dbo].[Budget_Detail] ADD  CONSTRAINT [DF_Budget_Detail_BDD_KeyCodArtProd]  DEFAULT ('') FOR [BDD_KeyCodArtProd]
GO
ALTER TABLE [dbo].[Budget_Detail] ADD  CONSTRAINT [DF_Budget_Detail_BDD_KeySOCRic]  DEFAULT ('') FOR [BDD_KeySOCRic]
GO
ALTER TABLE [dbo].[Budget_Detail] ADD  CONSTRAINT [DF_Budget_Detail_BDD_KeyPlantRic]  DEFAULT ('') FOR [BDD_KeyPlantRic]
GO
ALTER TABLE [dbo].[Budget_Detail] ADD  CONSTRAINT [DF_Budget_Detail_BDD_Commessa]  DEFAULT ('') FOR [BDD_Commessa]
GO
ALTER TABLE [dbo].[Budget_Detail] ADD  CONSTRAINT [DF_Budget_Detail_BDD_Check]  DEFAULT (0) FOR [BDD_Check]
GO
ALTER TABLE [dbo].[Budget_Detail] ADD  CONSTRAINT [DF_Budget_Detail_BDD_Level]  DEFAULT (1) FOR [BDD_Level]
GO
ALTER TABLE [dbo].[Budget_Detail] ADD  CONSTRAINT [DF_Budget_Detail_BDG_ECONOMO]  DEFAULT ('1') FOR [BDG_ECONOMO]
GO
