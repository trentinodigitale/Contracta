USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[OaPDettaglio]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OaPDettaglio](
	[IdDett] [int] IDENTITY(1,1) NOT NULL,
	[IdOaP] [int] NOT NULL,
	[IdMsg] [int] NOT NULL,
	[DescrArt] [nvarchar](1000) NULL,
	[ArtCode] [nvarchar](20) NOT NULL,
	[UM] [int] NOT NULL,
	[SediDest] [varchar](500) NOT NULL,
	[TipoRiga] [varchar](20) NOT NULL,
	[QOXAB] [float] NULL,
	[DataXAB] [datetime] NULL,
	[QOCumulataXAB] [float] NULL,
	[CodiceArtForn] [nvarchar](20) NULL,
	[DataForn] [datetime] NULL,
	[Variazione] [bit] NOT NULL,
	[NumXAB] [int] NULL,
	[Viewed] [bit] NOT NULL,
	[ViewedBuyer] [bit] NOT NULL,
	[ViewedForn] [bit] NOT NULL,
	[VariatoForn] [int] NOT NULL,
	[CodOperFase] [int] NULL,
	[Fase] [int] NULL,
	[Protocol] [nvarchar](12) NULL,
	[PeriodoTipologia] [int] NOT NULL,
	[IdArt] [int] NULL,
	[ResidualOrderQuantity] [float] NULL,
	[AcceptedProgrammeOrder] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OaPDettaglio] ADD  CONSTRAINT [DF_OaPDettaglio_Variazione]  DEFAULT (0) FOR [Variazione]
GO
ALTER TABLE [dbo].[OaPDettaglio] ADD  CONSTRAINT [DF__OAPDettag__Viewe__61A73897]  DEFAULT (0) FOR [Viewed]
GO
ALTER TABLE [dbo].[OaPDettaglio] ADD  CONSTRAINT [DF_OaPDettaglio_ViewedBuyer]  DEFAULT (0) FOR [ViewedBuyer]
GO
ALTER TABLE [dbo].[OaPDettaglio] ADD  CONSTRAINT [DF_OaPDettaglio_ViewedForn]  DEFAULT (0) FOR [ViewedForn]
GO
ALTER TABLE [dbo].[OaPDettaglio] ADD  CONSTRAINT [DF_OaPDettaglio_VariatoForn]  DEFAULT (0) FOR [VariatoForn]
GO
ALTER TABLE [dbo].[OaPDettaglio] ADD  CONSTRAINT [DF_OaPDettaglio_CodOperFase]  DEFAULT (0) FOR [CodOperFase]
GO
ALTER TABLE [dbo].[OaPDettaglio] ADD  CONSTRAINT [DF_OaPDettaglio_Fase]  DEFAULT (0) FOR [Fase]
GO
ALTER TABLE [dbo].[OaPDettaglio] ADD  CONSTRAINT [DF_OaPDettaglio_PeriodoTipologia]  DEFAULT (1) FOR [PeriodoTipologia]
GO
ALTER TABLE [dbo].[OaPDettaglio] ADD  CONSTRAINT [DF__OAPDettag__Accep__0626F234]  DEFAULT (0) FOR [AcceptedProgrammeOrder]
GO
