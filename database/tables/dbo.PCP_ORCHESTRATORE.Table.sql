USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[PCP_ORCHESTRATORE]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PCP_ORCHESTRATORE](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[Cod_Area_Funzionale] [nvarchar](5) NULL,
	[Cod_Famiglie_di_funzionalit] [nvarchar](5) NULL,
	[Settore_regime] [nvarchar](max) NULL,
	[fase] [nvarchar](50) NULL,
	[evento] [nvarchar](100) NULL,
	[schedaCodice] [nvarchar](20) NULL,
	[schedaVersione] [numeric](2, 1) NULL,
	[schedaDescrizione] [nvarchar](max) NULL,
	[schedaNormativa] [nvarchar](max) NULL,
	[pubblicazioneTED] [nvarchar](2) NULL,
	[eForm] [nvarchar](20) NULL,
	[includeESPD] [nvarchar](6) NULL,
	[includeAnacForm] [nvarchar](2) NULL,
	[pubblicazioneNazionale] [nvarchar](2) NULL,
	[schedaPreinformazione] [nvarchar](2) NULL,
	[schedaDiIndizione] [nvarchar](2) NULL,
	[attribuisceCIG] [nvarchar](2) NULL,
	[schedaSuccessiva] [nvarchar](max) NULL,
	[flussoAppartenenza] [nvarchar](200) NULL,
	[flussoUscita] [int] NULL,
	[regole] [nvarchar](20) NULL,
	[nuovoStatoAppalto] [nvarchar](20) NULL,
	[nuovoStatoLotto] [nvarchar](20) NULL,
	[nuovoStatoContratto] [nvarchar](20) NULL,
	[codiciSchedeCorrelate] [nvarchar](20) NULL,
	[dataInizio] [datetime] NULL,
	[dataFine] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdRow] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
