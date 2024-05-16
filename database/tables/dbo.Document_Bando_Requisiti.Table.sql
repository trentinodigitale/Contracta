USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Bando_Requisiti]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Bando_Requisiti](
	[idrow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[RequisitoGara] [varchar](20) NULL,
	[Valore] [decimal](18, 2) NULL,
	[Esclusione] [varchar](2) NULL,
	[ComprovaOfferta] [varchar](2) NULL,
	[Avvalimento] [varchar](2) NULL,
	[BandoTipo] [varchar](2) NULL,
	[Riservatezza] [varchar](2) NULL,
	[ElencoCIG] [varchar](max) NULL,
	[DescrizioneRequisito] [nvarchar](max) NULL,
	[esitoRichiesta] [varchar](20) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
