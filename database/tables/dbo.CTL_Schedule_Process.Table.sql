USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Schedule_Process]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Schedule_Process](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[IdDoc] [int] NOT NULL,
	[IdUser] [int] NULL,
	[DPR_DOC_ID] [varchar](200) NOT NULL,
	[DPR_ID] [varchar](200) NOT NULL,
	[DataRequestExec] [datetime] NULL,
	[DataExecuted] [datetime] NULL,
	[State] [varchar](20) NULL,
	[dateIn] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_Schedule_Process] ADD  CONSTRAINT [DF_CTL_Schedule_Process_State]  DEFAULT ('0') FOR [State]
GO
ALTER TABLE [dbo].[CTL_Schedule_Process] ADD  DEFAULT (getdate()) FOR [dateIn]
GO
