USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ScriptHistory]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScriptHistory](
	[IdSh] [int] IDENTITY(1,1) NOT NULL,
	[shCode] [char](12) NOT NULL,
	[shName] [varchar](100) NOT NULL,
	[shRelease] [varchar](10) NOT NULL,
	[shExecDate] [datetime] NOT NULL,
	[shDateDeleted] [datetime] NULL,
	[shDeleted] [bit] NOT NULL,
	[srpNote] [varchar](2000) NULL,
 CONSTRAINT [PK_ScriptHistory] PRIMARY KEY CLUSTERED 
(
	[IdSh] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ScriptHistory] ADD  CONSTRAINT [DF_ScriptHistory_shExecDate]  DEFAULT (getdate()) FOR [shExecDate]
GO
ALTER TABLE [dbo].[ScriptHistory] ADD  CONSTRAINT [DF_ScriptHistory_shDeleted]  DEFAULT (0) FOR [shDeleted]
GO
