USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[LIB_DomainValues]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LIB_DomainValues](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[DMV_DM_ID] [varchar](100) NULL,
	[DMV_Cod] [varchar](500) NULL,
	[DMV_Father] [varchar](255) NOT NULL,
	[DMV_Level] [int] NOT NULL,
	[DMV_DescML] [varchar](255) NOT NULL,
	[DMV_Image] [varchar](50) NULL,
	[DMV_Sort] [int] NULL,
	[DMV_CodExt] [varchar](500) NULL,
	[DMV_Module] [varchar](100) NULL,
	[DMV_Deleted] [int] NULL
) ON [PRIMARY]
GO
