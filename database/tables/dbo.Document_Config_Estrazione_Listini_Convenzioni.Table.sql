USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Config_Estrazione_Listini_Convenzioni]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Config_Estrazione_Listini_Convenzioni](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[PercorsoDiRete] [nvarchar](max) NOT NULL,
	[FrequenzaEstrazione] [varchar](50) NOT NULL,
	[OrarioAvvio] [varchar](8) NOT NULL,
	[SeparatoreCSV] [varchar](50) NOT NULL,
	[EMAIL] [nvarchar](1000) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
