USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_RDA]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_RDA](
	[RDA_ID] [int] IDENTITY(1,1) NOT NULL,
	[RDA_Owner] [varchar](20) NULL,
	[RDA_Name] [nvarchar](50) NULL,
	[RDA_DataCreazione] [datetime] NULL,
	[RDA_Protocol] [nvarchar](50) NULL,
	[RDA_Object] [nvarchar](1000) NULL,
	[RDA_Total] [float] NULL,
	[RDA_Stato] [nvarchar](20) NULL,
	[RDA_AZI] [nvarchar](10) NULL,
	[RDA_Plant_CDC] [nvarchar](50) NULL,
	[RDA_Valuta] [nvarchar](50) NULL,
	[RDA_InBudget] [nvarchar](10) NULL,
	[RDA_BDG_Periodo] [varchar](10) NULL,
	[RDA_Deleted] [char](1) NULL,
	[RDA_BuyerRole] [nvarchar](20) NULL,
	[RDA_ResidualBudget] [float] NULL,
	[RDA_CEO] [nvarchar](10) NULL,
	[RDA_SOCRic] [nvarchar](20) NULL,
	[RDA_PlantRic] [nvarchar](50) NULL,
	[RDA_MCE] [nvarchar](10) NULL,
	[RDA_DataScad] [datetime] NULL,
	[RDA_Utilizzo] [nvarchar](20) NULL,
	[RDA_Type] [nvarchar](20) NULL,
	[RDA_IT] [nvarchar](2) NULL,
	[RDA_Origin_InBudget] [nchar](10) NULL,
	[RefOrd] [varchar](100) NULL,
	[RefOrdInd] [varchar](200) NULL,
	[RefOrdTel] [varchar](20) NULL,
	[RefOrdEMail] [varchar](100) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_RDA] ADD  CONSTRAINT [DF_Document_RDA_RDA_InBudget]  DEFAULT (' ') FOR [RDA_InBudget]
GO
ALTER TABLE [dbo].[Document_RDA] ADD  CONSTRAINT [DF_Document_RDA_RDA_Deleted]  DEFAULT (' ') FOR [RDA_Deleted]
GO
ALTER TABLE [dbo].[Document_RDA] ADD  CONSTRAINT [DF_Document_RDA_RDA_ResidualBudget]  DEFAULT (0) FOR [RDA_ResidualBudget]
GO
ALTER TABLE [dbo].[Document_RDA] ADD  CONSTRAINT [DF_Document_RDA_RDA_CEO]  DEFAULT (' ') FOR [RDA_CEO]
GO
ALTER TABLE [dbo].[Document_RDA] ADD  CONSTRAINT [DF_Document_RDA_RDP_SOCRic]  DEFAULT ('') FOR [RDA_SOCRic]
GO
ALTER TABLE [dbo].[Document_RDA] ADD  CONSTRAINT [DF_Document_RDA_RDP_PlantRic]  DEFAULT ('') FOR [RDA_PlantRic]
GO
ALTER TABLE [dbo].[Document_RDA] ADD  CONSTRAINT [DF_Document_RDA_RDA_MCE]  DEFAULT (' ') FOR [RDA_MCE]
GO
ALTER TABLE [dbo].[Document_RDA] ADD  CONSTRAINT [DF_Document_RDA_RDA_Type]  DEFAULT (1) FOR [RDA_Type]
GO
ALTER TABLE [dbo].[Document_RDA] ADD  CONSTRAINT [DF_Document_RDA_RDA_IT]  DEFAULT (N'no') FOR [RDA_IT]
GO
