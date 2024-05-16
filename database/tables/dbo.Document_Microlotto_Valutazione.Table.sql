USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Microlotto_Valutazione]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Microlotto_Valutazione](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[TipoDoc] [varchar](100) NULL,
	[CriterioValutazione] [varchar](20) NULL,
	[DescrizioneCriterio] [nvarchar](255) NULL,
	[PunteggioMax] [float] NULL,
	[Formula] [nvarchar](4000) NULL,
	[AttributoCriterio] [nvarchar](255) NULL,
	[PunteggioMin] [float] NULL,
	[Eredita] [varchar](1) NULL,
	[Riparametra] [char](1) NULL,
	[Allegati_da_oscurare] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Microlotto_Valutazione] ADD  CONSTRAINT [DF_Document_Microlotto_Valutazione_Tipodoc]  DEFAULT ('LOTTO') FOR [TipoDoc]
GO
ALTER TABLE [dbo].[Document_Microlotto_Valutazione] ADD  CONSTRAINT [DF_Document_Microlotto_Valutazione_Riparametra]  DEFAULT ('1') FOR [Riparametra]
GO
