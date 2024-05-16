USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Estrazione_ListiniConvenzioni]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Estrazione_ListiniConvenzioni](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[IdDoc] [int] NOT NULL,
	[TipoDoc] [varchar](50) NOT NULL,
	[Protocollo] [varchar](50) NOT NULL,
	[Titolo] [nvarchar](500) NOT NULL,
	[DataInvio] [datetime] NOT NULL,
	[Esito] [varchar](20) NOT NULL,
	[NumRetry] [int] NOT NULL,
	[NumProdotti] [int] NOT NULL
) ON [PRIMARY]
GO
