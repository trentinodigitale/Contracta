USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Performance_Monitor]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Performance_Monitor](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[data] [datetime] NOT NULL,
	[server] [varchar](500) NULL,
	[totSessioniAttive] [int] NULL,
	[totModelliInMemoria] [int] NULL,
	[totDominiInMemoria] [int] NULL,
	[memoriaUsata] [int] NULL,
	[cpu] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_Performance_Monitor] ADD  CONSTRAINT [DF_CTL_Performance_Monitor_data]  DEFAULT (getdate()) FOR [data]
GO
