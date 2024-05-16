USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Configurazione_Monitor_Tipologie]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Configurazione_Monitor_Tipologie](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[Titolo_Tipologia] [nvarchar](500) NOT NULL,
	[Descrizione_Tipologia] [nvarchar](1000) NOT NULL,
	[ParoleChiavi_Tipologia] [nvarchar](2000) NOT NULL,
	[Soglia_Ultimi_3Mesi] [int] NULL,
	[Soglia_Ultimo_Mese] [int] NULL,
	[Soglia_Ultima_Settimana] [int] NULL,
	[Soglia_Oggi] [int] NULL,
	[Data_Notifica_U3Mesi] [datetime] NULL,
	[Data_Notifica_UMese] [datetime] NULL,
	[Data_Notifica_USettimana] [datetime] NULL,
	[Data_Notifica_Oggi] [datetime] NULL,
	[MailTo] [nvarchar](2000) NULL,
	[Deleted] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Configurazione_Monitor_Tipologie] ADD  CONSTRAINT [DF_Document_Configurazione_Monitor_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
