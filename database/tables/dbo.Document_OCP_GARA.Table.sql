USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_OCP_GARA]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_OCP_GARA](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[W3OGGETTO1] [nvarchar](2000) NULL,
	[W3IDGARA] [varchar](50) NULL,
	[W3I_GARA] [decimal](18, 2) NULL,
	[W3DGURI] [datetime] NULL,
	[W3DSCADB] [datetime] NULL,
	[W9GAMOD_IND] [varchar](10) NULL,
	[W9GAFLAG_ENT] [varchar](10) NULL,
	[W3TIPOAPP] [varchar](10) NULL,
	[W3ID_TIPOL] [varchar](10) NULL,
	[W9GASTIPULA] [varchar](5) NULL,
	[CFTEC1] [varchar](50) NULL,
	[COGTEI] [varchar](50) NULL,
	[NOMETEI] [varchar](50) NULL,
	[TELTEC1] [varchar](50) NULL,
	[G_EMATECI] [varchar](200) NULL,
	[W3PROFILO1] [varchar](5) NULL,
	[W3MIN1] [varchar](5) NULL,
	[W3OSS1] [varchar](5) NULL,
	[W9CCCODICE] [varchar](50) NULL,
	[W9CCDENOM] [nvarchar](500) NULL,
	[CFEIN] [varchar](100) NULL,
	[W9GADURACCQ] [int] NULL,
	[AllegatoPerOCP] [nvarchar](500) NULL,
	[DataIndizione] [datetime] NULL,
	[W9GADPUBB] [datetime] NULL,
	[W3FLAG_SA] [varchar](5) NULL,
	[W9GACAM] [varchar](5) NULL,
	[W9SISMA] [varchar](5) NULL,
	[W3NAZ1] [int] NULL,
	[W3REG1] [int] NULL,
	[W3GUCE1] [datetime] NULL,
	[W3GURI1] [datetime] NULL,
	[W3ALBO1] [datetime] NULL,
	[W9PBTIPDOC] [int] NULL,
	[W9PBDATAPUBB] [datetime] NULL,
	[W9PBDATASCAD] [datetime] NULL,
	[W9APOUSCOMP] [varchar](10) NULL,
	[W3PROCEDUR] [varchar](10) NULL,
	[W3PREINFOR] [varchar](10) NULL,
	[W3TERMINE] [varchar](10) NULL,
	[W3RELAZUNIC] [varchar](10) NULL
) ON [PRIMARY]
GO
