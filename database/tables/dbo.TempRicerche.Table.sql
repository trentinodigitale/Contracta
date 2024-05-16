USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempRicerche]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempRicerche](
	[IdRic] [int] NOT NULL,
	[ricTs] [timestamp] NOT NULL,
	[ricIdPfu] [int] NOT NULL,
	[ricIdMpi] [int] NOT NULL,
	[ricNome] [varchar](20) NOT NULL,
	[ricUltimoAgg] [datetime] NOT NULL,
	[ricTipoAgg] [tinyint] NOT NULL,
	[ricProssimoAgg] [datetime] NULL,
	[ricTotArticoli] [smallint] NOT NULL,
	[ricDeleted] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempRicerche] ADD  CONSTRAINT [DF_TempRicerche_ricIdMpi]  DEFAULT (0) FOR [ricIdMpi]
GO
ALTER TABLE [dbo].[TempRicerche] ADD  CONSTRAINT [DF_TempRicerche_ricUltimoAgg]  DEFAULT (1 / 1 / 1999) FOR [ricUltimoAgg]
GO
ALTER TABLE [dbo].[TempRicerche] ADD  CONSTRAINT [DF_TempRicerche_ricTotArticoli]  DEFAULT (0) FOR [ricTotArticoli]
GO
ALTER TABLE [dbo].[TempRicerche] ADD  CONSTRAINT [DF_TempRicerche_ricDeleted]  DEFAULT (0) FOR [ricDeleted]
GO
