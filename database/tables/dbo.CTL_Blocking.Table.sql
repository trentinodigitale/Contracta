USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Blocking]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Blocking](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Data] [datetime] NULL,
	[WaitingSessionID] [smallint] NULL,
	[BlockingSessionID] [smallint] NULL,
	[WaitingUserSessionLogin] [nvarchar](128) NOT NULL,
	[BlockingUserSessionLogin] [nvarchar](128) NOT NULL,
	[WaitingUserConnectionLogin] [nvarchar](128) NOT NULL,
	[BlockingSessionConnectionLogin] [nvarchar](128) NOT NULL,
	[WaitDuration] [bigint] NULL,
	[WaitType] [nvarchar](60) NULL,
	[WaitRequestMode] [nvarchar](60) NOT NULL,
	[WaitingProcessStatus] [nvarchar](30) NULL,
	[BlockingSessionStatus] [nvarchar](30) NULL,
	[WaitResource] [nvarchar](256) NOT NULL,
	[WaitResourceType] [nvarchar](60) NOT NULL,
	[WaitResourceDatabaseID] [int] NOT NULL,
	[WaitResourceDatabaseName] [nvarchar](128) NULL,
	[WaitResourceDescription] [nvarchar](2048) NULL,
	[WaitingSessionProgramName] [nvarchar](128) NULL,
	[BlockingSessionProgramName] [nvarchar](128) NULL,
	[WaitingHost] [nvarchar](128) NULL,
	[BlockingHost] [nvarchar](128) NULL,
	[WaitingCommandType] [nvarchar](16) NOT NULL,
	[WaitingCommandText] [nvarchar](max) NULL,
	[BlockingStmt] [nvarchar](max) NULL,
	[WaitingCommandRowCount] [bigint] NOT NULL,
	[WaitingCommandPercentComplete] [real] NOT NULL,
	[WaitingCommandCPUTime] [int] NOT NULL,
	[WaitingCommandTotalElapsedTime] [int] NOT NULL,
	[WaitingCommandReads] [bigint] NOT NULL,
	[WaitingCommandWrites] [bigint] NOT NULL,
	[WaitingCommandLogicalReads] [bigint] NOT NULL,
	[WaitingCommandQueryPlan] [xml] NULL,
	[WaitingCommandPlanHandle] [varbinary](64) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_Blocking] ADD  DEFAULT (getdate()) FOR [Data]
GO
