USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Configurazione_Variazione_Gestore]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Configurazione_Variazione_Gestore](
	[idrow] [int] IDENTITY(1,1) NOT NULL,
	[idheader] [int] NOT NULL,
	[deleted] [int] NULL,
	[MesiFrequenza] [int] NULL,
	[GiorniScadenza] [int] NULL,
	[mail_alert_pec_oe_ko] [nvarchar](255) NULL,
	[mail_alert_pec_ente_ko] [nvarchar](255) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Configurazione_Variazione_Gestore] ADD  CONSTRAINT [DF_Document_Configurazione_Variazione_Gestore_deleted]  DEFAULT ((0)) FOR [deleted]
GO
