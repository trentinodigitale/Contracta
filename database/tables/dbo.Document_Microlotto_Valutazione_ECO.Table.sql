USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Microlotto_Valutazione_ECO]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Microlotto_Valutazione_ECO](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[TipoDoc] [varchar](200) NULL,
	[DescrizioneCriterio] [nvarchar](255) NULL,
	[PunteggioMax] [float] NULL,
	[AttributoBase] [varchar](200) NULL,
	[AttributoValore] [varchar](200) NULL,
	[Coefficiente_X] [varchar](10) NULL,
	[FormulaEcoSDA] [nvarchar](max) NULL,
	[FormulaEconomica] [nvarchar](max) NULL,
	[CriterioFormulazioneOfferte] [varchar](20) NULL,
	[Alfa] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
