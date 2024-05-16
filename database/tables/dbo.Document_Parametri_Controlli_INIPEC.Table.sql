USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Parametri_Controlli_INIPEC]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Parametri_Controlli_INIPEC](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[NumeroMesi_Dominio] [varchar](10) NULL,
	[EMAIL] [nvarchar](1000) NULL,
	[ClientID] [nvarchar](200) NULL,
	[ClientSecret] [nvarchar](200) NULL,
	[OggettoAmmessa] [nvarchar](200) NULL,
	[TestoAmmessa] [nvarchar](max) NULL,
	[OggettoIntegrativa] [nvarchar](200) NULL,
	[TestoIntegrativa] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
