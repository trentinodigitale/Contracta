USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Budget_UserChoice]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Budget_UserChoice](
	[BDU_id] [char](10) NOT NULL,
	[BDU_Periodo] [char](10) NULL,
	[BDU_IdPfu] [char](10) NULL,
	[BDU_Check] [char](10) NULL,
	[BDU_BDD_id] [int] NOT NULL,
 CONSTRAINT [PK_Budget_UserChoice] PRIMARY KEY CLUSTERED 
(
	[BDU_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
