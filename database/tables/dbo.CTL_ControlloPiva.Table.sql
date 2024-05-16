USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_ControlloPiva]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_ControlloPiva](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[stato] [varchar](10) NULL,
	[maxlen] [int] NULL,
	[minlen] [int] NULL,
	[pattern] [varchar](50) NULL,
	[pattern_regexp] [varchar](200) NULL,
	[descrizione] [nvarchar](500) NULL,
	[codiceEsterno] [varchar](100) NULL
) ON [PRIMARY]
GO
