USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_EVENT_VIEWER_DATES]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_EVENT_VIEWER_DATES](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[dateEvent] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_EVENT_VIEWER_DATES] ADD  CONSTRAINT [DF_CTL_EVENT_VIEWER_DATES_dateEvent]  DEFAULT (getdate()) FOR [dateEvent]
GO
