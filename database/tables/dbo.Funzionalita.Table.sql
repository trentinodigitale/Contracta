USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Funzionalita]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Funzionalita](
	[IdFnz] [int] IDENTITY(1,1) NOT NULL,
	[fnzNomeGruppo] [varchar](50) NOT NULL,
	[fnzChiaveGruppo] [varchar](50) NOT NULL,
	[fnzSorgente] [varchar](50) NOT NULL,
	[fnzProfilo] [varchar](10) NOT NULL,
	[fnzUltimaMod] [datetime] NOT NULL,
	[fnzCancellato] [bit] NOT NULL,
 CONSTRAINT [PK_Funzionalita] PRIMARY KEY NONCLUSTERED 
(
	[IdFnz] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Funzionalita] ADD  CONSTRAINT [DF_Funzionalita_fnzUltimaMod]  DEFAULT (getdate()) FOR [fnzUltimaMod]
GO
ALTER TABLE [dbo].[Funzionalita] ADD  CONSTRAINT [DF_Funzionalita_fnzCancellato]  DEFAULT (0) FOR [fnzCancellato]
GO
