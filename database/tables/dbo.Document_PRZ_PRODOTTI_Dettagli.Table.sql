USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_PRZ_PRODOTTI_Dettagli]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_PRZ_PRODOTTI_Dettagli](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[TipoDoc] [varchar](50) NOT NULL,
	[StatoRiga] [varchar](50) NOT NULL,
	[Prezzo_Riga_Modificato] [varchar](50) NULL,
	[CODICE_REGIONALE] [nvarchar](100) NULL,
	[DESCRIZIONE_CODICE_REGIONALE] [nvarchar](500) NULL,
	[Quantita_CORRENTE] [float] NULL,
	[PREZZO_OFFERTO_PER_UM_CORRENTE] [float] NULL,
	[PREZZO_OFFERTO_PER_UM_VARIATO] [float] NULL,
	[PREZZO_ACCESSORIO_PER_UM] [float] NULL,
	[PREZZO_ACCESSORIO_PER_UM_VARIATO] [float] NULL,
	[idHeaderLotto] [int] NULL,
	[NotEditable] [nvarchar](255) NULL,
	[NoteLotto] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_PRZ_PRODOTTI_Dettagli] ADD  CONSTRAINT [DF_Document_PRZ_PRODOTTI_Dettagli_TipoDoc]  DEFAULT ('') FOR [TipoDoc]
GO
ALTER TABLE [dbo].[Document_PRZ_PRODOTTI_Dettagli] ADD  CONSTRAINT [DF_Document_PRZ_PRODOTTI_Dettagli_StatoRiga]  DEFAULT ('Saved') FOR [StatoRiga]
GO
ALTER TABLE [dbo].[Document_PRZ_PRODOTTI_Dettagli] ADD  CONSTRAINT [DF_Document_PRZ_PRODOTTI_Dettagli_Prezzo_Riga_Modificato]  DEFAULT ('no') FOR [Prezzo_Riga_Modificato]
GO
