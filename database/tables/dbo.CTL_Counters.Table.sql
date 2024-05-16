USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Counters]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Counters](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idAzi] [int] NULL,
	[Plant] [varchar](50) NULL,
	[Name] [varchar](50) NULL,
	[Period] [varchar](50) NULL,
	[Altro] [varchar](100) NULL,
	[Counter] [int] NULL
) ON [PRIMARY]
GO
