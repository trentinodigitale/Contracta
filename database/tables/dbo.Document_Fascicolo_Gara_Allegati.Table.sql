USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Fascicolo_Gara_Allegati]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Fascicolo_Gara_Allegati](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[Path] [nvarchar](1000) NULL,
	[Attach] [nvarchar](1000) NULL,
	[NomeFile] [nvarchar](1000) NULL,
	[IdDoc] [int] NOT NULL,
	[DSE_ID] [nvarchar](50) NOT NULL,
	[AreaDiAppartenenza] [varchar](1000) NULL,
	[Esito] [varchar](20) NOT NULL,
	[NumRetry] [int] NOT NULL,
	[Encrypted] [varchar](10) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Fascicolo_Gara_Allegati] ADD  CONSTRAINT [DF_Document_Fascicolo_Gara_Allegati_Esito]  DEFAULT ('') FOR [Esito]
GO
ALTER TABLE [dbo].[Document_Fascicolo_Gara_Allegati] ADD  CONSTRAINT [DF_Document_Fascicolo_Gara_Allegati_NumRetry]  DEFAULT ((0)) FOR [NumRetry]
GO
