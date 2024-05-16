USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_SERVICES]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_SERVICES](
	[srv_id] [int] NOT NULL,
	[data] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_SERVICES] ADD  CONSTRAINT [DF_CTL_SERVICES_data]  DEFAULT (getdate()) FOR [data]
GO
