USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Budget_Definition_Interval]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Budget_Definition_Interval](
	[BDI_ID] [int] IDENTITY(1,1) NOT NULL,
	[BDI_BDG_SelPeriodo] [varchar](10) NOT NULL,
	[BDI_Datainizio] [datetime] NULL,
	[BDI_DataFine] [datetime] NULL
) ON [PRIMARY]
GO
