USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Vincoli]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Vincoli](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[Espressione] [nvarchar](max) NULL,
	[Descrizione] [nvarchar](1000) NULL,
	[EsitoRiga] [nvarchar](500) NULL,
	[Seleziona] [varchar](50) NULL,
	[contesto_vincoli] [varchar](200) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
