USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Process]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Process](
	[IdPrc] [int] IDENTITY(1,1) NOT NULL,
	[prcIdMP] [int] NOT NULL,
	[prcITypeSource] [smallint] NOT NULL,
	[prcISubtypeSource] [smallint] NOT NULL,
	[prcIdProcess] [int] NOT NULL,
	[prcITypeDest] [smallint] NOT NULL,
	[prcISubtypeDest] [smallint] NOT NULL,
	[prcCondition] [varchar](500) NULL,
	[prcTypeCondition] [varchar](10) NULL,
	[prcOrder] [int] NOT NULL
) ON [PRIMARY]
GO
