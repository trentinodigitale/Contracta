USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[document_AVCP_Importi]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[document_AVCP_Importi](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[DataInizio] [datetime] NULL,
	[DataFine] [datetime] NULL,
	[DataLiquidazione] [datetime] NULL,
	[Importo] [float] NULL
) ON [PRIMARY]
GO
