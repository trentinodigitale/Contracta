USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Articoli]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Articoli](
	[IdArt] [int] IDENTITY(1,1) NOT NULL,
	[artIdAzi] [int] NOT NULL,
	[artCspValue] [int] NOT NULL,
	[artCode] [nvarchar](30) NOT NULL,
	[artIdDscDescrizione] [int] NOT NULL,
	[artIdUms] [int] NOT NULL,
	[artQMO] [int] NULL,
	[_artIdImballojkj] [int] NULL,
	[_artIdVatPrzUni] [int] NULL,
	[artDeleted] [bit] NOT NULL,
	[artSitoWeb] [nvarchar](300) NULL,
	[artUltimaMod] [datetime] NOT NULL,
	[DataInizioValiditaArt] [datetime] NULL,
	[DataFineValiditaArt] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Articoli] ADD  CONSTRAINT [DF_Articoli_artQMO]  DEFAULT (0) FOR [artQMO]
GO
ALTER TABLE [dbo].[Articoli] ADD  CONSTRAINT [DF_Articoli_artDeleted]  DEFAULT (0) FOR [artDeleted]
GO
ALTER TABLE [dbo].[Articoli] ADD  CONSTRAINT [DF_Articoli_artSitoWeb]  DEFAULT ('') FOR [artSitoWeb]
GO
ALTER TABLE [dbo].[Articoli] ADD  CONSTRAINT [DF_Articoli_artUltimaMod]  DEFAULT (getdate()) FOR [artUltimaMod]
GO
