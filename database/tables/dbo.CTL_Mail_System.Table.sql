USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Mail_System]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Mail_System](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TypeDoc] [varchar](50) NULL,
	[IdDoc] [int] NULL,
	[MailGuid] [nvarchar](255) NULL,
	[MailFrom] [nvarchar](255) NULL,
	[MailTo] [nvarchar](500) NULL,
	[MailObject] [nvarchar](500) NULL,
	[MailBody] [ntext] NULL,
	[MailCC] [nvarchar](500) NULL,
	[MailCCn] [nvarchar](500) NULL,
	[MailData] [datetime] NULL,
	[MailObj] [nvarchar](255) NULL,
	[IdPfuMitt] [int] NULL,
	[IdPfuDest] [int] NULL,
	[Status] [varchar](25) NULL,
	[IsFromPec] [tinyint] NULL,
	[IsToPec] [tinyint] NULL,
	[InOut] [char](3) NULL,
	[deleted] [tinyint] NULL,
	[DescrError] [ntext] NULL,
	[DataUpdate] [datetime] NULL,
	[NumRetry] [int] NULL,
	[idAziDest] [int] NULL,
	[DataSent] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_Mail_System] ADD  DEFAULT (1) FOR [Status]
GO
ALTER TABLE [dbo].[CTL_Mail_System] ADD  DEFAULT ('OUT') FOR [InOut]
GO
ALTER TABLE [dbo].[CTL_Mail_System] ADD  DEFAULT (0) FOR [deleted]
GO
ALTER TABLE [dbo].[CTL_Mail_System] ADD  DEFAULT (0) FOR [NumRetry]
GO
