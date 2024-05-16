USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempHye]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempHye](
	[CurNode] [varchar](20) NOT NULL,
	[RefNode] [varchar](20) NOT NULL,
	[I] [nvarchar](255) NULL,
	[UK] [nvarchar](255) NULL,
	[FRA] [nvarchar](255) NULL,
	[E] [nvarchar](255) NULL,
	[Lng1] [nvarchar](255) NULL,
	[Lng2] [nvarchar](255) NULL,
	[Lng3] [nvarchar](255) NULL,
	[Lng4] [nvarchar](255) NULL
) ON [PRIMARY]
GO
