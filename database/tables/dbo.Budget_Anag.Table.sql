USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Budget_Anag]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Budget_Anag](
	[BDG_Periodo] [varchar](10) NULL,
	[BDG_Stato] [varchar](10) NULL,
	[BDG_DataCreazione] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Budget_Anag] ADD  CONSTRAINT [DF_Budget_Anag_BDG_DataCreazione]  DEFAULT (getdate()) FOR [BDG_DataCreazione]
GO
