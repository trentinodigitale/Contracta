USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[PDND_Servizi]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PDND_Servizi](
	[IDServizio] [int] IDENTITY(1,1) NOT NULL,
	[IDContesto] [int] NOT NULL,
	[Method] [nvarchar](10) NOT NULL,
	[Endpoint] [nvarchar](100) NOT NULL,
	[QueryParameters] [nvarchar](max) NULL,
	[Tipo] [nchar](2) NULL,
	[CriterioControllo] [varchar](100) NULL,
	[Da_X_Giorni] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
