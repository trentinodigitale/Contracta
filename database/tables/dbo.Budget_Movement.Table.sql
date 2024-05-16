USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Budget_Movement]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Budget_Movement](
	[BDM_id] [int] IDENTITY(1,1) NOT NULL,
	[BDM_BDG_Periodo] [nvarchar](10) NOT NULL,
	[BDM_Data] [datetime] NOT NULL,
	[BDM_KeySOC] [nvarchar](20) NOT NULL,
	[BDM_KeyPlant] [nvarchar](30) NOT NULL,
	[BDM_KeyVDS] [nvarchar](20) NOT NULL,
	[BDM_KeyCDC] [nvarchar](20) NOT NULL,
	[BDM_KeyMerceologia] [nvarchar](20) NOT NULL,
	[BDM_KeyProgetto] [nvarchar](40) NULL,
	[BDM_KeyFornitore] [nvarchar](20) NULL,
	[BDM_KeyCodArtProd] [nvarchar](30) NULL,
	[BDM_Commessa] [nvarchar](20) NULL,
	[BDM_Importo] [float] NOT NULL,
	[BDM_OriginalImporto] [float] NOT NULL,
	[BDM_OriginalValuta] [nvarchar](20) NOT NULL,
	[BDM_isOld] [tinyint] NOT NULL,
	[BDM_Tiket] [varchar](20) NULL,
	[BDM_TypeMovement] [varchar](20) NULL,
	[BDM_KeyTipoInvestimento] [nvarchar](20) NULL,
	[BDM_KeySOCRic] [nvarchar](20) NULL,
	[BDM_KeyPlantRic] [nvarchar](30) NULL,
	[BDM_idPfu] [int] NULL,
	[BDM_IdMsg] [varchar](20) NULL,
	[BDM_NumOrd] [varchar](20) NULL,
	[BDM_Causale] [varchar](1000) NULL,
	[BDM_BDD_id] [int] NULL,
	[BDM_cpi] [varchar](20) NULL,
	[BDM_rprot] [varchar](20) NULL,
	[BDM_CDCRichiedente] [varchar](20) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Budget_Movement] ADD  CONSTRAINT [DF_Budget_Movement_BDM_Data]  DEFAULT (getdate()) FOR [BDM_Data]
GO
ALTER TABLE [dbo].[Budget_Movement] ADD  CONSTRAINT [DF_Budget_Movement_BDM_KeySOC]  DEFAULT ('') FOR [BDM_KeySOC]
GO
ALTER TABLE [dbo].[Budget_Movement] ADD  CONSTRAINT [DF_Budget_Movement_BDM_KeyMerceologia]  DEFAULT ('') FOR [BDM_KeyMerceologia]
GO
ALTER TABLE [dbo].[Budget_Movement] ADD  CONSTRAINT [DF_Budget_Movement_BDM_Commessa]  DEFAULT ('') FOR [BDM_Commessa]
GO
ALTER TABLE [dbo].[Budget_Movement] ADD  CONSTRAINT [DF_Budget_Movement_BDM_Importo]  DEFAULT (0) FOR [BDM_Importo]
GO
ALTER TABLE [dbo].[Budget_Movement] ADD  CONSTRAINT [DF_Budget_Movement_BDD_OriginalImporto]  DEFAULT (0) FOR [BDM_OriginalImporto]
GO
ALTER TABLE [dbo].[Budget_Movement] ADD  CONSTRAINT [DF_Budget_Movement_BDD_OriginalValuta]  DEFAULT (1) FOR [BDM_OriginalValuta]
GO
ALTER TABLE [dbo].[Budget_Movement] ADD  CONSTRAINT [DF_Budget_Movement_BDD_KeySOCRic]  DEFAULT ('') FOR [BDM_KeySOCRic]
GO
ALTER TABLE [dbo].[Budget_Movement] ADD  CONSTRAINT [DF_Budget_Movement_BDD_KeyPlantRic]  DEFAULT ('') FOR [BDM_KeyPlantRic]
GO
