USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Convenzione_Lotti]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Convenzione_Lotti](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[Seleziona] [varchar](10) NULL,
	[StatoLottoConvenzione] [varchar](10) NULL,
	[NumeroLotto] [varchar](50) NULL,
	[Descrizione] [nvarchar](1000) NULL,
	[Importo] [float] NULL,
	[Impegnato] [float] NULL,
	[Estensione] [float] NULL,
	[Finale] [float] NULL,
	[Residuo] [float] NULL,
	[SogliaSuperata] [int] NULL,
	[DataAlertSoglia] [datetime] NULL,
	[CodiceAIC] [nvarchar](max) NULL,
	[CODICE_CND] [nvarchar](max) NULL,
	[CodiceATC] [nvarchar](max) NULL,
	[CODICE_CPV] [nvarchar](max) NULL,
	[PrincipioAttivo] [nvarchar](max) NULL,
	[DESCRIZIONE_CODICE_REGIONALE] [nvarchar](max) NULL,
	[TotalOrigine] [float] NULL,
	[ValoreRinnoviOpzioni] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
