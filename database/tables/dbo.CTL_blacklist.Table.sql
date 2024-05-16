USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_blacklist]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_blacklist](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ip] [varchar](100) NOT NULL,
	[statoBlocco] [nvarchar](100) NOT NULL,
	[dataBlocco] [datetime] NOT NULL,
	[dataRefresh] [datetime] NULL,
	[numeroRefresh] [int] NULL,
	[paginaAttaccata] [nvarchar](300) NULL,
	[queryString] [nvarchar](max) NULL,
	[idPfu] [int] NULL,
	[form] [nvarchar](1500) NULL,
	[motivoBlocco] [nvarchar](4000) NOT NULL,
	[guid] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_blacklist] ADD  CONSTRAINT [DF_blacklist_numeroRefresh]  DEFAULT ((0)) FOR [numeroRefresh]
GO
