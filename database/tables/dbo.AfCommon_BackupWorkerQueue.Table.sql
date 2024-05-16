USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[AfCommon_BackupWorkerQueue]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AfCommon_BackupWorkerQueue](
	[id] [varchar](450) NOT NULL,
	[creationdate] [datetime] NOT NULL,
	[action] [varchar](max) NULL,
	[esit] [bit] NULL,
	[message] [varchar](max) NULL,
	[displayonform] [bit] NOT NULL,
	[stacktrace] [varchar](max) NULL,
	[operation] [varchar](max) NULL,
	[idpfu] [int] NULL,
	[sessionid] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
