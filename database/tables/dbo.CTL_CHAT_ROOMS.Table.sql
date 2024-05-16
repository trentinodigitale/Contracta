USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_CHAT_ROOMS]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_CHAT_ROOMS](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[Title] [nvarchar](max) NULL,
	[Owner] [int] NULL,
	[Chat_Stato] [nvarchar](20) NULL,
	[DateStart] [datetime] NULL,
	[DateEnd] [datetime] NULL,
	[LastUpd] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
