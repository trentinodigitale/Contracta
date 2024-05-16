USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MIGR_UTENTI_FORN]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MIGR_UTENTI_FORN](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PARTITA_IVA] [nvarchar](255) NULL,
	[NOME_UTENTE] [nvarchar](255) NULL,
	[NOME] [nvarchar](255) NULL,
	[COGNOME] [nvarchar](255) NULL,
	[QUALIFICA] [nvarchar](255) NULL,
	[EMAIL] [nvarchar](255) NULL,
	[TELEFONO] [nvarchar](255) NULL,
	[LINGUA] [nvarchar](255) NULL,
	[CODICE_FISCALE] [nvarchar](255) NULL,
	[PROFILO_1] [nvarchar](255) NULL,
	[PROFILO_2] [nvarchar](255) NULL,
	[PROFILO_3] [nvarchar](255) NULL,
	[PROFILO_4] [nvarchar](255) NULL,
	[PROFILO_5] [nvarchar](255) NULL,
	[CARICATO] [bit] NOT NULL,
	[NOTE] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[MIGR_UTENTI_FORN] ADD  DEFAULT ((0)) FOR [CARICATO]
GO
ALTER TABLE [dbo].[MIGR_UTENTI_FORN] ADD  DEFAULT ('') FOR [NOTE]
GO
