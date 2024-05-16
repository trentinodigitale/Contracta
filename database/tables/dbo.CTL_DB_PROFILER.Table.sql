USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_DB_PROFILER]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_DB_PROFILER](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[data] [datetime] NOT NULL,
	[tempoEsecuzione] [int] NULL,
	[scriptSQL] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_DB_PROFILER] ADD  CONSTRAINT [DF__CTL_DB_PRO__data__1E148350]  DEFAULT (getdate()) FOR [data]
GO
