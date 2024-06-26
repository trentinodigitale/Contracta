USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TAB_RICERCHE]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TAB_RICERCHE](
	[IdMp] [int] NULL,
	[IdAzi] [int] NOT NULL,
	[IdPfu] [int] NULL,
	[TipoRicerca] [varchar](10) NOT NULL,
	[Esito] [bit] NOT NULL,
	[DataEsecuzione] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAB_RICERCHE] ADD  CONSTRAINT [DF_TAB_RICERCHE_Esito]  DEFAULT (0) FOR [Esito]
GO
ALTER TABLE [dbo].[TAB_RICERCHE] ADD  CONSTRAINT [DF_TAB_RICERCHE_DataEsecuzione]  DEFAULT (getdate()) FOR [DataEsecuzione]
GO
