USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[PDND_Dati_ANAC]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PDND_Dati_ANAC](
	[IdAzi] [bigint] NOT NULL,
	[CodiceAusa] [varchar](20) NOT NULL,
	[CentroDiCosto] [varchar](60) NOT NULL,
	[CodicePiattaformaAnac] [varchar](50) NULL,
	[userLoa] [int] NULL,
	[IdTipoUtente] [varchar](30) NULL,
	[PRIVATE_KEY] [nvarchar](max) NULL,
	[PCP_regCodiceComponente] [varchar](100) NULL,
	[urlAuth] [nvarchar](max) NULL,
	[audAuth] [nvarchar](max) NULL,
 CONSTRAINT [PK_PDND_Dati_ANAC] PRIMARY KEY CLUSTERED 
(
	[IdAzi] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
