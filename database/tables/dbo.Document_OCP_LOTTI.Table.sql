USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_OCP_LOTTI]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_OCP_LOTTI](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[NumeroLotto] [varchar](10) NULL,
	[W3OGGETTO2] [nvarchar](2000) NULL,
	[W3CIG] [varchar](20) NULL,
	[W3I_LOTTO] [decimal](18, 2) NULL,
	[W3CPV] [varchar](20) NULL,
	[W3ID_SCEL2] [varchar](20) NULL,
	[W3ID_CATE4] [varchar](50) NULL,
	[W3MANOLO] [varchar](5) NULL,
	[W3TIPO_CON] [varchar](5) NULL,
	[W3MOD_GAR] [varchar](10) NULL,
	[W3LUOGO_IS] [varchar](20) NULL,
	[W3LUOGO_NU] [varchar](20) NULL,
	[W3ID_TIPO] [varchar](10) NULL,
	[W3ID_APP04] [varchar](10) NULL,
	[W3ID_APP05] [varchar](10) NULL,
	[W9INSCAD] [datetime] NULL,
	[W9INDECO] [datetime] NULL,
	[W3DATA_ESE] [datetime] NULL,
	[W3DATA_STI] [datetime] NULL,
	[esitoOCP] [varchar](100) NULL,
	[datiOK] [varchar](100) NULL,
	[W3NLOTTO] [int] NULL,
	[W3I_ATTSIC] [decimal](18, 2) NULL,
	[W9CUIINT] [varchar](50) NULL
) ON [PRIMARY]
GO
