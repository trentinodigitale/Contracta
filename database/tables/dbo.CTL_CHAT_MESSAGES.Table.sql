USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_CHAT_MESSAGES]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_CHAT_MESSAGES](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[idPfu] [int] NULL,
	[DataIns] [datetime] NULL,
	[Message] [nvarchar](max) NULL,
	[Type] [varchar](20) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
