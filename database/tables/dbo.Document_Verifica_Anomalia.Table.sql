USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Verifica_Anomalia]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Verifica_Anomalia](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[aziRagioneSociale] [nvarchar](max) NULL,
	[id_rowLottoOff] [int] NULL,
	[id_rowOffPDA] [int] NULL,
	[PunteggioTecnico] [float] NULL,
	[PunteggioEconomico] [float] NULL,
	[PunteggioTotale] [float] NULL,
	[Ribasso] [float] NULL,
	[ScartoAritmetico] [float] NULL,
	[TaglioAli] [nvarchar](20) NULL,
	[Motivazione] [ntext] NULL,
	[StatoAnomalia] [nvarchar](200) NULL,
	[NotEdit] [nvarchar](500) NULL,
	[RibassoAssoluto] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
