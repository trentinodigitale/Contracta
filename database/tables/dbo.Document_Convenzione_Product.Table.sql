USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Convenzione_Product]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Convenzione_Product](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[Progressivo] [nvarchar](20) NULL,
	[Marca] [nvarchar](200) NULL,
	[Codice] [nvarchar](300) NULL,
	[Descrizione] [nvarchar](4000) NULL,
	[Merceologia] [varchar](50) NULL,
	[QtMin] [float] NULL,
	[PrezzoUnitario] [float] NULL,
	[Nota] [ntext] NULL,
	[PercSconto] [float] NULL,
	[CoefCorr] [float] NULL,
	[CostoComplessivo] [float] NULL,
	[RicPropBozza] [varchar](50) NULL,
	[ImportoCompenso] [float] NULL,
	[IVA] [varchar](5) NULL,
	[QtMax] [float] NULL,
	[TipoProdotto] [varchar](200) NULL,
	[Immagine] [nvarchar](250) NULL,
	[Brochure] [nvarchar](250) NULL,
	[ArticoliCollegati] [nvarchar](1000) NULL,
	[UnitMis] [nvarchar](250) NULL,
	[QtMaxRow] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'quantità massima acquistabile' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Document_Convenzione_Product', @level2type=N'COLUMN',@level2name=N'QtMax'
GO
