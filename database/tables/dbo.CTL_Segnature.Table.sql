USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Segnature]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Segnature](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idDoc] [int] NULL,
	[allegato] [nvarchar](1000) NULL,
	[segnature_xml] [nvarchar](max) NULL,
	[oggettoProtocollo] [nvarchar](1000) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
