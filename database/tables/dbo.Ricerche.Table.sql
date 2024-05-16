USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Ricerche]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ricerche](
	[IdRic] [int] IDENTITY(1,1) NOT NULL,
	[ricTs] [timestamp] NOT NULL,
	[ricIdPfu] [int] NOT NULL,
	[ricIdMpi] [int] NOT NULL,
	[ricNome] [varchar](20) NOT NULL,
	[ricUltimoAgg] [datetime] NOT NULL,
	[ricTipoAgg] [tinyint] NOT NULL,
	[ricProssimoAgg] [datetime] NULL,
	[ricTotArticoli] [smallint] NOT NULL,
	[ricDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_Ricerche] PRIMARY KEY NONCLUSTERED 
(
	[IdRic] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Ricerche] ADD  CONSTRAINT [DF_Ricerche_ricIdMpi]  DEFAULT (0) FOR [ricIdMpi]
GO
ALTER TABLE [dbo].[Ricerche] ADD  CONSTRAINT [DF_Ricerche_ricUltimoAgg]  DEFAULT (1 / 1 / 1999) FOR [ricUltimoAgg]
GO
ALTER TABLE [dbo].[Ricerche] ADD  CONSTRAINT [DF_Ricerche_ricTotArticoli]  DEFAULT (0) FOR [ricTotArticoli]
GO
ALTER TABLE [dbo].[Ricerche] ADD  CONSTRAINT [DF_Ricerche_ricDeleted]  DEFAULT (0) FOR [ricDeleted]
GO
ALTER TABLE [dbo].[Ricerche]  WITH NOCHECK ADD  CONSTRAINT [FK_Ricerche_ProfiliUtente] FOREIGN KEY([ricIdPfu])
REFERENCES [dbo].[ProfiliUtente] ([IdPfu])
GO
ALTER TABLE [dbo].[Ricerche] CHECK CONSTRAINT [FK_Ricerche_ProfiliUtente]
GO
