USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Save_CTL_CONFIG_MAIL_20231113]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Save_CTL_CONFIG_MAIL_20231113](
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
