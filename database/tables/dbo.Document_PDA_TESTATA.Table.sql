USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_PDA_TESTATA]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_PDA_TESTATA](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[ImportoBaseAsta] [float] NULL,
	[ImportoBaseAsta2] [float] NULL,
	[DataAperturaOfferte] [datetime] NULL,
	[CriterioAggiudicazioneGara] [varchar](50) NULL,
	[OffAnomale] [varchar](50) NULL,
	[ModalitadiPartecipazione] [varchar](50) NULL,
	[CriterioFormulazioneOfferte] [varchar](50) NULL,
	[CUP] [varchar](max) NULL,
	[CIG] [varchar](50) NULL,
	[DataIISeduta] [datetime] NULL,
	[NumeroIndizione] [varchar](50) NULL,
	[DataIndizione] [datetime] NULL,
	[NRDeterminazione] [varchar](50) NULL,
	[Oggetto] [ntext] NULL,
	[DataDetermina] [datetime] NULL,
	[ListaModelliMicrolotti] [varchar](100) NULL,
	[DirezioneProponente] [varchar](50) NULL,
	[RequestSignTemp] [varchar](50) NULL,
	[Conformita] [varchar](20) NULL,
	[TipoBandoGara] [varchar](20) NULL,
	[ProceduraGara] [varchar](50) NULL,
	[RichiestaCampionatura] [varchar](20) NULL,
	[PunteggioTEC_100] [varchar](50) NULL,
	[PunteggioTEC_TipoRip] [varchar](50) NULL,
	[IS_EX_POST] [varchar](50) NULL,
	[IS_EX_ANTE] [varchar](50) NULL,
	[IS_OEV] [varchar](50) NULL,
	[IS_PRZ] [varchar](50) NULL,
	[RICHIESTA_CALCOLO_ANOMALIA] [varchar](50) NULL,
	[PunteggioECO_TipoRip] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
