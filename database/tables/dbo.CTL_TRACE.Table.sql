USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_TRACE]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_TRACE](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[data] [datetime] NOT NULL,
	[contesto] [varchar](4000) NULL,
	[sessionIdASP] [varchar](4000) NULL,
	[sessionIdApp] [varchar](4000) NULL,
	[idpfu] [int] NULL,
	[idDoc] [int] NULL,
	[descrizione] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_TRACE] ADD  CONSTRAINT [DF_CTL_TRACE_data]  DEFAULT (getdate()) FOR [data]
GO
