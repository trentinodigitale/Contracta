USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_LOG_DECODIFICA]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_LOG_DECODIFICA](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[URL] [varchar](400) NULL,
	[CriterioDecodifica] [varchar](8000) NULL
) ON [PRIMARY]
GO
