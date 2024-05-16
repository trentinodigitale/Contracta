USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Microlotto_PunteggioLotto]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Microlotto_PunteggioLotto](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeaderLottoOff] [int] NULL,
	[idRowValutazione] [int] NULL,
	[Punteggio] [float] NULL,
	[PunteggioRiparametrato] [float] NULL,
	[Giudizio] [varchar](20) NULL,
	[Note] [ntext] NULL,
	[GiudizioRiparametrato] [float] NULL,
	[PunteggioOriginale] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
