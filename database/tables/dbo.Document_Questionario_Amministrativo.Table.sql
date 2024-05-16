USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Questionario_Amministrativo]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Questionario_Amministrativo](
	[idrow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[KeyRiga] [varchar](200) NOT NULL,
	[TipoRigaQuestionario] [varchar](100) NOT NULL,
	[Descrizione] [nvarchar](500) NULL,
	[DescrizioneEstesa] [nvarchar](max) NULL,
	[TipoParametroQuestionario] [varchar](100) NULL,
	[Tech_Info_Parametro] [nvarchar](max) NULL,
	[EsitoRiga] [nvarchar](max) NULL,
	[EsitoRiga_Parametro] [nvarchar](max) NULL,
	[ChiaveUnivocaRiga] [int] NOT NULL,
	[Valori_Di_Esclusione_Parametro] [nvarchar](max) NULL,
	[SezioniCondizionate] [nvarchar](max) NULL,
	[ElencoValori] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
