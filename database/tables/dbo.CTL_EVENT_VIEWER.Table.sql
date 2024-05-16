USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_EVENT_VIEWER]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_EVENT_VIEWER](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[data] [datetime] NOT NULL,
	[tipoEvento] [int] NULL,
	[source] [nvarchar](max) NULL,
	[descrizione] [nvarchar](max) NULL,
	[idpfu] [int] NULL,
	[hashError] [nvarchar](500) NULL,
	[errorCount] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_EVENT_VIEWER] ADD  CONSTRAINT [DF__CTL_EVENT___data__20F0EFFB]  DEFAULT (getdate()) FOR [data]
GO
