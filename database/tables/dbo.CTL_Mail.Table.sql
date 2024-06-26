USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Mail]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Mail](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[IdDoc] [int] NOT NULL,
	[IdUser] [int] NULL,
	[TypeDoc] [varchar](200) NOT NULL,
	[State] [varchar](20) NULL,
	[dateIn] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_Mail] ADD  CONSTRAINT [DF_CTL_Mail_dateIn]  DEFAULT (getdate()) FOR [dateIn]
GO
