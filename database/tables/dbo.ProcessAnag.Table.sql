USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ProcessAnag]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProcessAnag](
	[IdProcess] [int] IDENTITY(1,1) NOT NULL,
	[Descr] [varchar](101) NULL
) ON [PRIMARY]
GO
