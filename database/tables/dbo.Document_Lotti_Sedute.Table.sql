USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Lotti_Sedute]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Lotti_Sedute](
	[IdSeduta] [int] IDENTITY(1,1) NOT NULL,
	[IdRow] [int] NOT NULL,
	[NumeroSeduta] [varchar](50) NULL,
	[DescrizioneSeduta] [varchar](100) NULL,
	[DataSeduta] [datetime] NULL
) ON [PRIMARY]
GO
