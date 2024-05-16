USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[AF_Temp_Prov]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AF_Temp_Prov](
	[id] [float] NULL,
	[DMV_DM_ID] [nvarchar](255) NULL,
	[DMV_Cod] [nvarchar](255) NULL,
	[DMV_Father] [float] NULL,
	[DMV_Level] [float] NULL,
	[DMV_DescML] [nvarchar](255) NULL,
	[DMV_Image] [nvarchar](255) NULL,
	[DMV_Sort] [float] NULL,
	[DMV_CodExt] [float] NULL,
	[DMV_Module] [nvarchar](255) NULL,
	[DMV_Deleted] [nvarchar](255) NULL
) ON [PRIMARY]
GO
