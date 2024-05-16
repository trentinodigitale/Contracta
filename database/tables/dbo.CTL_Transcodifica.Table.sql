USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Transcodifica]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Transcodifica](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[dztNome] [varchar](50) NULL,
	[Plant] [varchar](50) NULL,
	[Sistema] [varchar](50) NULL,
	[ValIn] [nvarchar](2000) NULL,
	[ValOut] [nvarchar](2000) NULL
) ON [PRIMARY]
GO
