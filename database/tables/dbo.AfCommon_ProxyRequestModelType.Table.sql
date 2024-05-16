USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[AfCommon_ProxyRequestModelType]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AfCommon_ProxyRequestModelType](
	[id] [varchar](450) NOT NULL,
	[fx] [varchar](max) NULL,
	[creationdate] [datetime] NOT NULL,
	[url] [varchar](max) NULL,
	[ipaddress] [varchar](max) NULL,
	[query] [nvarchar](max) NULL,
	[form] [nvarchar](max) NULL,
	[ref_url] [varchar](max) NULL,
	[ref_query] [nvarchar](max) NULL,
 CONSTRAINT [PK_AfCommon_ProxyRequestModelType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
