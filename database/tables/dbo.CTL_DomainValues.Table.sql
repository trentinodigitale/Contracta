USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_DomainValues]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_DomainValues](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[DMV_DM_ID] [varchar](100) NULL,
	[DMV_LNG] [varchar](10) NULL,
	[DMV_Cod] [varchar](500) NULL,
	[DMV_Father] [varchar](255) NOT NULL,
	[DMV_Level] [int] NOT NULL,
	[DMV_DescML] [nvarchar](max) NOT NULL,
	[DMV_Image] [varchar](50) NULL,
	[DMV_Sort] [int] NULL,
	[DMV_CodExt] [varchar](500) NULL,
	[DMV_Module] [varchar](100) NULL,
	[DMV_Deleted] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_DomainValues] ADD  CONSTRAINT [DF_CTL_DomainValues_DMV_LNG]  DEFAULT ('I') FOR [DMV_LNG]
GO
ALTER TABLE [dbo].[CTL_DomainValues] ADD  CONSTRAINT [DF_CTL_DomainValues_DMV_Father]  DEFAULT ('') FOR [DMV_Father]
GO
ALTER TABLE [dbo].[CTL_DomainValues] ADD  CONSTRAINT [DF_CTL_DomainValues_DMV_Level]  DEFAULT ('') FOR [DMV_Level]
GO
ALTER TABLE [dbo].[CTL_DomainValues] ADD  CONSTRAINT [DF_CTL_DomainValues_DMV_DescML]  DEFAULT ('') FOR [DMV_DescML]
GO
