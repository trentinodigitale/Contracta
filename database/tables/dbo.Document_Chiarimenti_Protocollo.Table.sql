USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Chiarimenti_Protocollo]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Chiarimenti_Protocollo](
	[idrow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[dzt_name] [varchar](500) NULL,
	[value] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
