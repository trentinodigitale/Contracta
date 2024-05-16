USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[document_AVCP_lotti]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[document_AVCP_lotti](
	[Idrow] [int] IDENTITY(1,1) NOT NULL,
	[idheader] [int] NOT NULL,
	[Anno] [nvarchar](50) NULL,
	[Cig] [nvarchar](200) NULL,
	[CFprop] [nvarchar](50) NULL,
	[Denominazione] [nvarchar](300) NULL,
	[Scelta_contraente] [nvarchar](50) NULL,
	[ImportoAggiudicazione] [float] NULL,
	[DataInizio] [datetime] NULL,
	[Datafine] [datetime] NULL,
	[ImportoSommeLiquidate] [float] NULL,
	[Oggetto] [nvarchar](max) NULL,
	[DataPubblicazione] [datetime] NULL,
	[Warning] [nvarchar](max) NULL,
	[NumeroLotto] [varchar](50) NULL,
	[idBando] [int] NULL,
	[StatoElaborazione] [int] NULL,
	[CigOriginale] [nvarchar](200) NULL,
	[GUIDBandoGen] [varchar](500) NULL,
	[tipobandogara] [varchar](500) NULL,
	[TipoDocBando] [varchar](100) NULL,
	[LastUpdate] [datetime] NULL,
	[Note] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
