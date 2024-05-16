USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_PDA_Sedute]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_PDA_Sedute](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[NumeroSeduta] [int] NULL,
	[TipoSeduta] [varchar](20) NULL,
	[Descrizione] [nvarchar](500) NULL,
	[DataInizio] [datetime] NULL,
	[DataFine] [datetime] NULL,
	[idPdA] [int] NULL,
	[idVerbale] [int] NULL,
	[idSeduta] [int] NULL,
	[Allegato] [nvarchar](255) NULL,
	[FaseSeduta] [varchar](20) NULL
) ON [PRIMARY]
GO
