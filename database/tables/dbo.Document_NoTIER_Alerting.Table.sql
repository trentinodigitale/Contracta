USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_NoTIER_Alerting]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_NoTIER_Alerting](
	[idAzi] [int] NOT NULL,
	[data] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_NoTIER_Alerting] ADD  CONSTRAINT [DF__Document_N__data__480ABD1C]  DEFAULT (getdate()) FOR [data]
GO
