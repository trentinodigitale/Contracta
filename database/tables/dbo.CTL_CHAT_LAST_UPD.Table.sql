USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_CHAT_LAST_UPD]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_CHAT_LAST_UPD](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[idPfu] [int] NULL,
	[LastUpd] [datetime] NULL
) ON [PRIMARY]
GO
