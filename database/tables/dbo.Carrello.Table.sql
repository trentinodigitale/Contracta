USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Carrello]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Carrello](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Marca] [nvarchar](50) NULL,
	[Linea] [nvarchar](50) NULL,
	[Modello] [nvarchar](50) NULL,
	[Codice] [nvarchar](100) NULL,
	[Categoria] [nvarchar](20) NULL,
	[Descrizione] [nvarchar](4000) NULL,
	[Nota] [ntext] NULL,
	[QtMin] [smallint] NULL,
	[QTDisp] [float] NULL,
	[Composizione] [nvarchar](50) NULL,
	[Fascia] [nvarchar](20) NULL,
	[PrezzoUnitario] [float] NULL,
	[Foto] [nvarchar](100) NULL,
	[Colore] [nvarchar](50) NULL,
	[deleted] [int] NULL,
	[idPfu] [int] NULL,
	[QtaXconf] [float] NULL,
	[NumConf] [float] NULL,
	[Plant] [varchar](50) NULL,
	[Id_Convenzione] [varchar](50) NULL,
	[Fornitore] [int] NULL,
	[Id_Product] [int] NULL,
	[TipoOrdine] [nchar](1) NULL,
	[ImportoCompenso] [float] NULL,
	[UnitMis] [nvarchar](250) NULL,
	[Immagine] [nvarchar](250) NULL,
	[Brochure] [nvarchar](250) NULL,
	[TipoProdotto] [varchar](250) NULL,
	[ToDelete] [int] NULL,
	[RicPreventivo] [varchar](10) NULL,
	[NumeroRepertorio] [nvarchar](500) NULL,
	[NumeroLotto] [varchar](50) NULL,
	[Voce] [int] NULL,
	[Importo_Residuo_Quote] [float] NULL,
	[Iva] [float] NULL,
	[Titolo] [nvarchar](500) NULL,
	[ValoreAccessorioTecnico] [float] NULL,
	[Not_Editable] [varchar](500) NULL,
	[EsitoRiga] [nvarchar](4000) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
