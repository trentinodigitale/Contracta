USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[document_AVCP_Import_CSV]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[document_AVCP_Import_CSV](
	[Idrow] [int] IDENTITY(1,1) NOT NULL,
	[idheader] [int] NOT NULL,
	[Anno] [nvarchar](50) NULL,
	[NumeroAutorita] [nvarchar](200) NULL,
	[Cig] [nvarchar](200) NULL,
	[CFprop] [nvarchar](50) NULL,
	[Denominazione] [nvarchar](300) NULL,
	[Scelta_contraente] [nvarchar](200) NULL,
	[ImportoAggiudicazione] [float] NULL,
	[DataInizio] [datetime] NULL,
	[Datafine] [datetime] NULL,
	[ImportoSommeLiquidate] [float] NULL,
	[Oggetto] [ntext] NULL,
	[DataPubblicazione] [datetime] NULL,
	[Warning] [ntext] NULL,
	[Gruppo] [nvarchar](4000) NULL,
	[Ruolopartecipante] [nvarchar](200) NULL,
	[Estero] [char](1) NULL,
	[Codicefiscale] [varchar](50) NULL,
	[CodicefiscaleEstero] [varchar](50) NULL,
	[Ragionesociale] [nvarchar](1000) NULL,
	[aggiudicatario] [char](1) NULL,
	[EsitoRiga] [nvarchar](4000) NULL,
	[numeroRiga] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
