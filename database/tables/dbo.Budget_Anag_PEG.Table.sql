USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Budget_Anag_PEG]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Budget_Anag_PEG](
	[BDG_Periodo] [varchar](10) NULL,
	[BDG_Stato] [varchar](10) NULL,
	[BDG_DataCreazione] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Budget_Anag_PEG] ADD  CONSTRAINT [DF__Budget_An__BDG_D__4DCB8C07]  DEFAULT (getdate()) FOR [BDG_DataCreazione]
GO
