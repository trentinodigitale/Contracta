USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_CONFIG_MAIL]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_CONFIG_MAIL](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Alias] [varchar](255) NOT NULL,
	[UsingMethod] [tinyint] NOT NULL,
	[Server] [varchar](50) NOT NULL,
	[ServerPort] [int] NOT NULL,
	[UseSSL] [tinyint] NOT NULL,
	[connectiontimeout] [int] NOT NULL,
	[Authenticate] [tinyint] NOT NULL,
	[UserName] [varchar](255) NOT NULL,
	[Password] [nvarchar](255) NOT NULL,
	[MailFrom] [varchar](255) NOT NULL,
	[AliasFrom] [varchar](500) NOT NULL,
	[BodyFormat] [varchar](50) NOT NULL,
	[NotificationTo] [varchar](255) NOT NULL,
	[ReceiptTo] [varchar](255) NOT NULL,
	[DSNOptions] [tinyint] NOT NULL,
	[Certified] [tinyint] NOT NULL,
	[StartTLS] [tinyint] NULL,
	[ServerRead] [varchar](50) NULL,
	[ServerPortRead] [int] NULL,
	[LoginMethod] [varchar](50) NOT NULL,
	[JsonToken] [varchar](max) NULL,
	[DateUpdateToken] [datetime] NULL,
	[FrequencyUpdateToken] [int] NULL,
	[ClientId] [varchar](max) NULL,
	[ClientSecret] [varchar](max) NULL,
	[TokenEndpoint] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_CONFIG_MAIL] ADD  CONSTRAINT [DF_CTL_CONFIG_MAIL_UsingMethod]  DEFAULT (1) FOR [UsingMethod]
GO
ALTER TABLE [dbo].[CTL_CONFIG_MAIL] ADD  CONSTRAINT [DF_CTL_CONFIG_MAIL_Server]  DEFAULT ('') FOR [Server]
GO
ALTER TABLE [dbo].[CTL_CONFIG_MAIL] ADD  CONSTRAINT [DF_CTL_CONFIG_MAIL_ServerPort]  DEFAULT (25) FOR [ServerPort]
GO
ALTER TABLE [dbo].[CTL_CONFIG_MAIL] ADD  CONSTRAINT [DF_CTL_CONFIG_MAIL_UseSSL]  DEFAULT (0) FOR [UseSSL]
GO
ALTER TABLE [dbo].[CTL_CONFIG_MAIL] ADD  CONSTRAINT [DF_CTL_CONFIG_MAIL_connectiontimeout]  DEFAULT (15) FOR [connectiontimeout]
GO
ALTER TABLE [dbo].[CTL_CONFIG_MAIL] ADD  CONSTRAINT [DF_CTL_CONFIG_MAIL_Authenticate]  DEFAULT (1) FOR [Authenticate]
GO
ALTER TABLE [dbo].[CTL_CONFIG_MAIL] ADD  CONSTRAINT [DF_CTL_CONFIG_MAIL_UserName]  DEFAULT ('') FOR [UserName]
GO
ALTER TABLE [dbo].[CTL_CONFIG_MAIL] ADD  CONSTRAINT [DF_CTL_CONFIG_MAIL_Password]  DEFAULT ('') FOR [Password]
GO
ALTER TABLE [dbo].[CTL_CONFIG_MAIL] ADD  CONSTRAINT [DF_CTL_CONFIG_MAIL_AliasFrom]  DEFAULT ('') FOR [AliasFrom]
GO
ALTER TABLE [dbo].[CTL_CONFIG_MAIL] ADD  CONSTRAINT [DF_CTL_CONFIG_MAIL_BodyFormat]  DEFAULT ('HTML') FOR [BodyFormat]
GO
ALTER TABLE [dbo].[CTL_CONFIG_MAIL] ADD  CONSTRAINT [DF_CTL_CONFIG_MAIL_NotificationTo]  DEFAULT ('') FOR [NotificationTo]
GO
ALTER TABLE [dbo].[CTL_CONFIG_MAIL] ADD  CONSTRAINT [DF_CTL_CONFIG_MAIL_ReceiptTo]  DEFAULT ('') FOR [ReceiptTo]
GO
ALTER TABLE [dbo].[CTL_CONFIG_MAIL] ADD  CONSTRAINT [DF_CTL_CONFIG_MAIL_DSNOptions]  DEFAULT (0) FOR [DSNOptions]
GO
ALTER TABLE [dbo].[CTL_CONFIG_MAIL] ADD  CONSTRAINT [DF_CTL_CONFIG_MAIL_Certified]  DEFAULT (0) FOR [Certified]
GO
ALTER TABLE [dbo].[CTL_CONFIG_MAIL] ADD  DEFAULT ('LOGIN') FOR [LoginMethod]
GO
ALTER TABLE [dbo].[CTL_CONFIG_MAIL] ADD  DEFAULT (getdate()) FOR [DateUpdateToken]
GO
ALTER TABLE [dbo].[CTL_CONFIG_MAIL] ADD  DEFAULT ((-1)) FOR [FrequencyUpdateToken]
GO
