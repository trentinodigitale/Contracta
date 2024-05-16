USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_OCP_LOTTI_AGGIUDICATI]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_OCP_LOTTI_AGGIUDICATI](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[NumeroLotto] [varchar](10) NULL,
	[W3OGGETTO2] [nvarchar](2000) NULL,
	[W3CIG] [varchar](20) NULL,
	[W3MOD_IND] [varchar](10) NULL,
	[W3IMPR_AMM] [int] NULL,
	[W3IMPR_OFF] [int] NULL,
	[W3DVERB] [datetime] NULL,
	[W3DSCAPO] [datetime] NULL,
	[W3IMP_AGGI] [decimal](18, 2) NULL,
	[W3PERC_RIB] [decimal](18, 2) NULL,
	[W3FLAG_RIC] [varchar](10) NULL,
	[W3OFFE_MAX] [decimal](18, 2) NULL,
	[W3OFFE_MIN] [decimal](18, 2) NULL,
	[W3I_SUBTOT] [decimal](18, 2) NULL,
	[W9APDATA_STI] [datetime] NULL,
	[W3PERC_OFF] [decimal](18, 2) NULL,
	[W9LOESIPROC] [varchar](2) NULL,
	[FILE_ALLEGATO] [nvarchar](1000) NULL,
	[esitoOCP] [varchar](100) NULL,
	[datiOK] [int] NULL,
	[W3ID_FINAN] [varchar](2) NULL,
	[W3I_FINANZ] [decimal](18, 2) NULL
) ON [PRIMARY]
GO
