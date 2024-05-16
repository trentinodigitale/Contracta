USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Actions]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Actions](
	[IdAct] [int] NOT NULL,
	[actDescr] [varchar](101) NULL,
	[actType] [varchar](500) NOT NULL,
	[actProgID] [varchar](50) NULL,
	[actLink] [varchar](50) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO
