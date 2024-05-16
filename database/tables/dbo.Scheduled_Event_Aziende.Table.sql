USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Scheduled_Event_Aziende]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Scheduled_Event_Aziende](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EVENT] [varchar](50) NOT NULL,
	[IDAZI] [int] NOT NULL,
	[NUM_ATTEMPT] [tinyint] NOT NULL,
	[DATE_LASTATTEMPT] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Scheduled_Event_Aziende] ADD  CONSTRAINT [DF_SCHEDULED_EVENT_INFOAZIENDE_NUM_ATTEMPT]  DEFAULT (0) FOR [NUM_ATTEMPT]
GO
ALTER TABLE [dbo].[Scheduled_Event_Aziende] ADD  CONSTRAINT [DF_Scheduled_Event_Aziende_DATE_LASTATTEMPT]  DEFAULT (getdate()) FOR [DATE_LASTATTEMPT]
GO
