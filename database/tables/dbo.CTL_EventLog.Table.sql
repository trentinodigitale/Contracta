USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_EventLog]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_EventLog](
	[Id] [int] NULL,
	[LevelDisplayName] [varchar](255) NULL,
	[LogName] [varchar](255) NULL,
	[MachineName] [varchar](255) NULL,
	[Message] [varchar](max) NULL,
	[ProviderName] [varchar](255) NULL,
	[RecordID] [bigint] NULL,
	[TaskDisplayName] [varchar](255) NULL,
	[TimeCreated] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
