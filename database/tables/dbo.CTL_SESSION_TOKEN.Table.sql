USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_SESSION_TOKEN]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_SESSION_TOKEN](
	[token] [nvarchar](1000) NOT NULL,
	[idpfu] [int] NOT NULL,
	[lastAccess] [datetime] NOT NULL,
	[sessionData] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
