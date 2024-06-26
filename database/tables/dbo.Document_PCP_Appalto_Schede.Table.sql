USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_PCP_Appalto_Schede]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_PCP_Appalto_Schede](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[bDeleted] [int] NOT NULL,
	[dateInsert] [datetime] NULL,
	[dateLastRetry] [datetime] NULL,
	[tipoScheda] [varchar](100) NULL,
	[statoScheda] [varchar](100) NULL,
	[numRetryEsitoOperazione] [int] NULL,
	[idScheda] [varchar](200) NULL,
	[IdDoc_Scheda] [int] NULL,
	[CIG] [varchar](max) NULL,
	[DatiElaborazione] [varchar](max) NULL,
	[idContratto] [varchar](100) NULL,
	[IdAvviso] [varchar](200) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_PCP_Appalto_Schede] ADD  CONSTRAINT [DF_Document_PCP_Appalto_Schede_bDeleted]  DEFAULT ((0)) FOR [bDeleted]
GO
ALTER TABLE [dbo].[Document_PCP_Appalto_Schede] ADD  CONSTRAINT [DF_Document_PCP_Appalto_Schede_numRetryEsitoOperazione]  DEFAULT ((0)) FOR [numRetryEsitoOperazione]
GO
