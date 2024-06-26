USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Budget_Movement_PEG]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Budget_Movement_PEG](
	[BDM_id] [int] IDENTITY(1,1) NOT NULL,
	[BDM_BDG_Periodo] [nvarchar](10) NOT NULL,
	[BDM_Data] [datetime] NOT NULL,
	[BDM_KeyEnte] [nvarchar](20) NOT NULL,
	[BDM_KeyArea] [nvarchar](30) NOT NULL,
	[BDM_KeyCDR] [nvarchar](20) NOT NULL,
	[BDM_KeyUAC] [nvarchar](20) NOT NULL,
	[BDM_KeyPegCDC] [nvarchar](20) NOT NULL,
	[BDM_KeyCodIntervento] [nvarchar](20) NULL,
	[BDM_KeyCapitolo] [nvarchar](20) NOT NULL,
	[BDM_KeyProgetto] [nvarchar](40) NULL,
	[BDM_Fornitore] [varchar](20) NULL,
	[BDM_Importo] [float] NOT NULL,
	[BDM_OriginalImporto] [float] NOT NULL,
	[BDM_OriginalValuta] [nvarchar](20) NOT NULL,
	[BDM_isOld] [tinyint] NOT NULL,
	[BDM_Tiket] [varchar](20) NULL,
	[BDM_TypeMovement] [varchar](20) NULL,
	[BDM_idPfu] [int] NULL,
	[BDM_IdMsg] [varchar](20) NULL,
	[BDM_Document] [varchar](50) NULL,
	[BDM_BDD_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Budget_Movement_PEG] ADD  CONSTRAINT [DF__Budget_Mo__BDM_D__5C19AB5E]  DEFAULT (getdate()) FOR [BDM_Data]
GO
ALTER TABLE [dbo].[Budget_Movement_PEG] ADD  CONSTRAINT [DF__Budget_Mo__BDM_K__5D0DCF97]  DEFAULT ('') FOR [BDM_KeyEnte]
GO
ALTER TABLE [dbo].[Budget_Movement_PEG] ADD  CONSTRAINT [DF__Budget_Mo__BDM_K__5E01F3D0]  DEFAULT ('') FOR [BDM_KeyCapitolo]
GO
ALTER TABLE [dbo].[Budget_Movement_PEG] ADD  CONSTRAINT [DF__Budget_Mo__BDM_I__5EF61809]  DEFAULT (0) FOR [BDM_Importo]
GO
ALTER TABLE [dbo].[Budget_Movement_PEG] ADD  CONSTRAINT [DF__Budget_Mo__BDM_O__5FEA3C42]  DEFAULT (0) FOR [BDM_OriginalImporto]
GO
ALTER TABLE [dbo].[Budget_Movement_PEG] ADD  CONSTRAINT [DF__Budget_Mo__BDM_O__60DE607B]  DEFAULT (1) FOR [BDM_OriginalValuta]
GO
