USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[AfCommon_MainWorkerQueueEntryModelType]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AfCommon_MainWorkerQueueEntryModelType](
	[id] [varchar](450) NOT NULL,
	[identifier] [varchar](max) NULL,
	[creationdate] [datetime] NOT NULL,
	[action] [varchar](max) NULL,
	[esit] [bit] NULL,
	[message] [varchar](max) NULL,
	[displayonform] [bit] NOT NULL,
	[stacktrace] [varchar](max) NULL,
	[mainstart] [datetime] NULL,
	[started] [datetime] NULL,
	[lastupdate] [datetime] NULL,
	[operation] [varchar](max) NULL,
	[progress] [float] NOT NULL,
	[settings] [nvarchar](max) NULL,
	[outputscripts] [nvarchar](max) NULL,
	[displayvariables] [nvarchar](max) NULL,
	[returnactions] [nvarchar](max) NULL,
	[lockid] [varchar](max) NULL,
	[locktime] [datetime] NULL,
	[idpfu] [int] NULL,
	[sessionid] [varchar](max) NULL,
	[lastclientupdate] [datetime] NULL,
 CONSTRAINT [PK_AfCommon_MainWorkerQueueEntryModelType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
