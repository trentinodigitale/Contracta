USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Convenzione_Prodotti_Principale]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Convenzione_Prodotti_Principale](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdRowProdotto] [int] NOT NULL,
	[IdConvenzione] [int] NOT NULL,
	[IdRowPrincipale] [int] NOT NULL
) ON [PRIMARY]
GO
