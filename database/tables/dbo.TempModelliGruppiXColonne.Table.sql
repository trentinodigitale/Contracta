USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempModelliGruppiXColonne]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempModelliGruppiXColonne](
	[mgcIdMgr] [int] NOT NULL,
	[mgcIdMcl] [int] NOT NULL,
	[mgcPesoFva] [tinyint] NULL,
	[mgcIdFva] [int] NULL,
	[mgcIdVatDefault] [int] NULL
) ON [PRIMARY]
GO
