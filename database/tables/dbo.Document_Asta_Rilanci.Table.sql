USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Asta_Rilanci]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Asta_Rilanci](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[idHeaderLottoOff] [int] NULL,
	[idAziFornitore] [int] NULL,
	[NumeroLotto] [int] NULL,
	[ValoreRilancio] [float] NULL,
	[DataRilancio] [datetime] NOT NULL,
	[ValoreRibasso] [float] NULL,
	[ValoreEconomico] [float] NULL,
	[ValoreSconto] [float] NULL
) ON [PRIMARY]
GO
