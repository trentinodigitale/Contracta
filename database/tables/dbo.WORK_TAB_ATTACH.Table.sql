USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[WORK_TAB_ATTACH]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WORK_TAB_ATTACH](
	[IdAtt] [int] IDENTITY(1,1) NOT NULL,
	[attIdMsg] [int] NOT NULL,
	[attIdObj] [int] NULL,
	[attOrderFile] [int] NULL
) ON [PRIMARY]
GO
