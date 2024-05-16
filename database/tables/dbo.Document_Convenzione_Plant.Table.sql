USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Convenzione_Plant]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Convenzione_Plant](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[Plant] [varchar](max) NULL,
	[AZI_Ente] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
