USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Questionario_Fornitore_Punteggi]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Questionario_Fornitore_Punteggi](
	[idrow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[IdAzi] [int] NULL,
	[IdDocForn] [int] NULL,
	[Punteggio] [float] NULL,
	[PunteggioGenerale] [float] NULL,
	[PunteggioTecnico] [float] NULL,
	[DataUltimaValutazione] [datetime] NULL,
	[DataScadenzaAbilitazione] [datetime] NULL,
	[DataPrimaValutazione] [datetime] NULL,
	[StatoAbilitazione] [varchar](50) NULL,
	[PunteggioMedio] [float] NULL,
	[PunteggioReqFacolt] [float] NULL,
	[NumeroQuestionariNonConformi] [varchar](20) NULL,
	[DataUltimaComunicazione] [datetime] NULL,
	[MercForn] [varchar](5000) NULL
) ON [PRIMARY]
GO
