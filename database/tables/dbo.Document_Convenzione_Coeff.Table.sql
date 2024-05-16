USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Convenzione_Coeff]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Convenzione_Coeff](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[Fascia_Da] [int] NULL,
	[Fascia_A] [int] NULL,
	[Coefficiente] [float] NULL
) ON [PRIMARY]
GO
