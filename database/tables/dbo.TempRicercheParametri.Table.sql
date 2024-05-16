USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempRicercheParametri]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempRicercheParametri](
	[rpmIdRic] [int] NOT NULL,
	[rpmIdVat] [int] NOT NULL,
	[rpmFunzione] [tinyint] NOT NULL,
	[rpmRelOrdine] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempRicercheParametri] ADD  CONSTRAINT [DF_TempRicercheParametri_rpmFunzione]  DEFAULT (0) FOR [rpmFunzione]
GO
