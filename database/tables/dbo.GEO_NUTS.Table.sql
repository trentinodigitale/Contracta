USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[GEO_NUTS]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GEO_NUTS](
	[Code] [nvarchar](4000) NULL,
	[Name] [nvarchar](4000) NULL,
	[Level] [nvarchar](4000) NULL,
	[CountryOrder] [nvarchar](4000) NULL,
	[OriginalSortingOrder] [nvarchar](4000) NULL,
	[change2006] [nvarchar](4000) NULL,
	[SortingOrder2003] [nvarchar](4000) NULL,
	[NUTS2003version] [nvarchar](4000) NULL,
	[Code2003] [nvarchar](4000) NULL,
	[Name2003] [nvarchar](4000) NULL,
	[Level2003] [nvarchar](4000) NULL,
	[CountryOrder2003] [nvarchar](4000) NULL,
	[OriginalSortingOrder2003] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
