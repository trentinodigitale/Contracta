USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Aziende_Informazioni]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Aziende_Informazioni](
	[IdAzi] [int] NOT NULL,
	[RichiestaCD] [bit] NOT NULL,
	[ContrattoFirmato] [bit] NOT NULL,
	[DataAggDatiAzienda] [datetime] NULL,
	[ScadenzaContratto] [datetime] NULL,
 CONSTRAINT [PK_Aziende_Informazioni] PRIMARY KEY NONCLUSTERED 
(
	[IdAzi] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Aziende_Informazioni] ADD  CONSTRAINT [DF_Aziende_Informazioni_RichiestaCD]  DEFAULT (0) FOR [RichiestaCD]
GO
ALTER TABLE [dbo].[Aziende_Informazioni] ADD  CONSTRAINT [DF_Aziende_Informazioni_ContrattoFirmato]  DEFAULT (0) FOR [ContrattoFirmato]
GO
ALTER TABLE [dbo].[Aziende_Informazioni] ADD  CONSTRAINT [DF_Aziende_Informazioni_ScadenzaContratto]  DEFAULT ('1 - 1 - 9999') FOR [ScadenzaContratto]
GO
