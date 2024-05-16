USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_OCP_IMPRESE_AGGIUDICATARIE]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_OCP_IMPRESE_AGGIUDICATARIE](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[idAzi] [int] NULL,
	[CFIMP] [varchar](100) NULL,
	[NOMIMP] [nvarchar](4000) NULL,
	[W3AGIDGRP] [int] NULL,
	[W3ID_TIPOA] [varchar](10) NULL,
	[W3RUOLO] [varchar](10) NULL,
	[W3FLAG_AVV] [varchar](10) NULL,
	[G_NAZIMP] [varchar](10) NULL,
	[INDIMP] [nvarchar](1000) NULL,
	[NCIIMP] [varchar](10) NULL,
	[LOCIMP] [nvarchar](1000) NULL,
	[TELIMP] [nvarchar](100) NULL,
	[FAXIMP] [nvarchar](100) NULL,
	[EMAI2IP] [nvarchar](1000) NULL,
	[NCCIAA] [varchar](100) NULL,
	[AGGAUS] [varchar](10) NULL,
	[CAPIMP] [varchar](20) NULL,
	[CFIMP_AUSILIARIA] [varchar](20) NULL,
	[W3AGIMP_AGGI] [float] NULL,
	[W3AGPERC_OFF] [decimal](18, 2) NULL,
	[W3AGPERC_RIB] [decimal](18, 2) NULL
) ON [PRIMARY]
GO
