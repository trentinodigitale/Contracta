USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[RicercheParametri]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RicercheParametri](
	[rpmIdRic] [int] NOT NULL,
	[rpmIdVat] [int] NOT NULL,
	[rpmFunzione] [tinyint] NOT NULL,
	[rpmRelOrdine] [tinyint] NOT NULL,
 CONSTRAINT [UN_RicercheParametri_IdVat] UNIQUE NONCLUSTERED 
(
	[rpmIdVat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RicercheParametri] ADD  CONSTRAINT [DF_RicercheParametri_rpmFunzione]  DEFAULT (0) FOR [rpmFunzione]
GO
ALTER TABLE [dbo].[RicercheParametri]  WITH CHECK ADD  CONSTRAINT [FK_RicercheParametri_Ricerche] FOREIGN KEY([rpmIdRic])
REFERENCES [dbo].[Ricerche] ([IdRic])
GO
ALTER TABLE [dbo].[RicercheParametri] CHECK CONSTRAINT [FK_RicercheParametri_Ricerche]
GO
ALTER TABLE [dbo].[RicercheParametri]  WITH CHECK ADD  CONSTRAINT [FK_RicercheParametri_ValoriAttributi] FOREIGN KEY([rpmIdVat])
REFERENCES [dbo].[ValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[RicercheParametri] CHECK CONSTRAINT [FK_RicercheParametri_ValoriAttributi]
GO
