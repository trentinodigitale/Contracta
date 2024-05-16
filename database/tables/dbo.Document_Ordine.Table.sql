USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Ordine]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Ordine](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdMsg] [int] NULL,
	[iType] [smallint] NULL,
	[iSubType] [smallint] NULL,
	[DataIns] [datetime] NULL,
	[NumOrd] [varchar](50) NULL,
	[Protocol] [varchar](50) NULL,
	[StatoOrdine] [varchar](50) NULL,
	[StateOrder] [char](2) NULL,
	[Plant] [varchar](255) NULL,
	[Name] [varchar](255) NULL,
	[IdDestinatario] [int] NULL,
	[IdAziDest] [int] NULL,
	[IdMittente] [int] NULL,
	[Nota] [nvarchar](4000) NULL,
	[FlagSituazione] [char](1) NULL,
	[STOrderCode] [varchar](50) NULL,
	[Deleted] [tinyint] NULL,
	[Total] [float] NULL,
	[Valuta] [varchar](20) NULL,
	[IVA] [int] NULL,
	[ImpegnoSpesa] [nvarchar](200) NULL,
	[TotalIva] [float] NULL,
	[ODC_PEG] [varchar](50) NULL,
	[Capitolo] [varchar](20) NULL,
	[NumeroConvenzione] [varchar](20) NULL,
	[ReferenteConsegna] [nvarchar](50) NULL,
	[ReferenteIndirizzo] [nvarchar](50) NULL,
	[ReferenteTelefono] [nvarchar](50) NULL,
	[ReferenteEMail] [nvarchar](50) NULL,
	[ReferenteRitiro] [nvarchar](50) NULL,
	[IndirizzoRitiro] [nvarchar](50) NULL,
	[TelefonoRitiro] [nvarchar](50) NULL,
	[Id_Convenzione] [int] NULL,
	[RitiroEMail] [varchar](100) NULL,
	[RefOrd] [varchar](100) NULL,
	[RefOrdInd] [varchar](200) NULL,
	[RefOrdTel] [varchar](20) NULL,
	[RefOrdEMail] [varchar](100) NULL,
	[RicPropBozza] [varchar](50) NOT NULL,
	[RDP_DataPrevCons] [datetime] NULL,
	[TipoOrdine] [nchar](1) NULL,
	[AllegatoConsegna] [nvarchar](255) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Ordine] ADD  CONSTRAINT [DF__document___FlagS__033D9A20]  DEFAULT (' ') FOR [FlagSituazione]
GO
ALTER TABLE [dbo].[Document_Ordine] ADD  CONSTRAINT [DF__document___Delet__0431BE59]  DEFAULT (0) FOR [Deleted]
GO
ALTER TABLE [dbo].[Document_Ordine] ADD  CONSTRAINT [DF_document_ordine_RicPropBozza]  DEFAULT (0) FOR [RicPropBozza]
GO
