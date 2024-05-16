USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[PARER_VERSAMENTO_PREGRESSO]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PARER_VERSAMENTO_PREGRESSO](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idODC] [int] NULL,
	[idPfuODC] [int] NULL,
	[registroSistemaODC] [varchar](100) NULL,
	[dataInvioODC] [datetime] NULL,
	[rspicConvenzione] [varchar](100) NULL,
	[dataRecord] [datetime] NULL,
	[dataRichiestaVersamento] [datetime] NULL,
	[idRowServIntegReq] [int] NULL
) ON [PRIMARY]
GO
