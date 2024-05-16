USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Genera_Buste_Offerta]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Genera_Buste_Offerta](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[CodiceOperazione] [varchar](100) NULL,
	[NumeroLotto] [int] NULL,
	[IdLotto] [int] NULL,
	[Busta] [varchar](50) NULL
) ON [PRIMARY]
GO
