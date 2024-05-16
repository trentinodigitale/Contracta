USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Fax]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Fax](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[IdDoc] [varchar](50) NOT NULL,
	[TypeDoc] [varchar](200) NOT NULL,
	[StateFax] [varchar](1) NULL
) ON [PRIMARY]
GO
