USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Budget_Detail_PEG]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Budget_Detail_PEG](
	[BDD_BDG_Periodo] [nvarchar](10) NOT NULL,
	[BDD_DataCreazione] [datetime] NOT NULL,
	[BDD_KeyEnte] [nvarchar](20) NOT NULL,
	[BDD_KeyArea] [nvarchar](30) NOT NULL,
	[BDD_KeyCDR] [nvarchar](20) NOT NULL,
	[BDD_KeyUAC] [nvarchar](20) NOT NULL,
	[BDD_KeyPegCDC] [nvarchar](20) NOT NULL,
	[BDD_KeyCodIntervento] [nvarchar](20) NULL,
	[BDD_KeyCapitolo] [nvarchar](30) NULL,
	[BDD_KeyProgetto] [nvarchar](40) NULL,
	[BDD_Importo] [float] NULL,
	[BDD_Check] [int] NOT NULL,
	[BDD_Level] [nvarchar](20) NOT NULL,
	[BDD_id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Budget_Detail_PEG] ADD  CONSTRAINT [DF__Budget_De__BDD_D__5660D208]  DEFAULT (getdate()) FOR [BDD_DataCreazione]
GO
ALTER TABLE [dbo].[Budget_Detail_PEG] ADD  CONSTRAINT [DF__Budget_De__BDD_K__5754F641]  DEFAULT ('') FOR [BDD_KeyCapitolo]
GO
ALTER TABLE [dbo].[Budget_Detail_PEG] ADD  CONSTRAINT [DF__Budget_De__BDD_K__58491A7A]  DEFAULT ('') FOR [BDD_KeyProgetto]
GO
ALTER TABLE [dbo].[Budget_Detail_PEG] ADD  CONSTRAINT [DF__Budget_De__BDD_C__593D3EB3]  DEFAULT (0) FOR [BDD_Check]
GO
ALTER TABLE [dbo].[Budget_Detail_PEG] ADD  CONSTRAINT [DF__Budget_De__BDD_L__5A3162EC]  DEFAULT (1) FOR [BDD_Level]
GO
