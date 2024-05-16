USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Parametri_Sedute_Virtuali]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Parametri_Sedute_Virtuali](
	[idrow] [int] IDENTITY(1,1) NOT NULL,
	[idheader] [int] NOT NULL,
	[deleted] [int] NULL,
	[Visualizza_Comunicazione] [varchar](200) NULL,
	[Singolo_Lotto] [varchar](200) NULL,
	[Lista_Lotti] [varchar](200) NULL,
	[Visibilita_Lotti] [varchar](200) NULL,
	[Visualizza_Dati_Amministrativi] [varchar](200) NULL,
	[Chiusura] [varchar](200) NULL,
	[Apertura] [varchar](200) NULL,
	[Visibilita] [varchar](200) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Parametri_Sedute_Virtuali] ADD  CONSTRAINT [DF_Document_Parametri_Sedute_Virtuali_deleted]  DEFAULT ((0)) FOR [deleted]
GO
