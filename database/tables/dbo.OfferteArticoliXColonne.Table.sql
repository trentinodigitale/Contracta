USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[OfferteArticoliXColonne]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OfferteArticoliXColonne](
	[oacIdOar] [int] NOT NULL,
	[oacIdMcl] [int] NOT NULL,
	[oacIdVat] [int] NOT NULL,
	[oacWarning] [bit] NOT NULL,
	[oacObblig] [bit] NOT NULL,
	[oacIdProd] [int] NULL,
 CONSTRAINT [UN_OfferteArticoliXColonne] UNIQUE NONCLUSTERED 
(
	[oacIdVat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OfferteArticoliXColonne] ADD  CONSTRAINT [DF_OfferteArticoliXColonne_OacWarning]  DEFAULT (0) FOR [oacWarning]
GO
ALTER TABLE [dbo].[OfferteArticoliXColonne] ADD  CONSTRAINT [DF_OfferteArticoliXColonne_oacObblig]  DEFAULT (0) FOR [oacObblig]
GO
ALTER TABLE [dbo].[OfferteArticoliXColonne]  WITH CHECK ADD  CONSTRAINT [FK_OfferteArticoliXColonne_ModelliColonne] FOREIGN KEY([oacIdMcl])
REFERENCES [dbo].[ModelliColonne] ([IdMcl])
GO
ALTER TABLE [dbo].[OfferteArticoliXColonne] CHECK CONSTRAINT [FK_OfferteArticoliXColonne_ModelliColonne]
GO
ALTER TABLE [dbo].[OfferteArticoliXColonne]  WITH CHECK ADD  CONSTRAINT [FK_OfferteArticoliXColonne_OfferteArticoli] FOREIGN KEY([oacIdOar])
REFERENCES [dbo].[OfferteArticoli] ([IdOar])
GO
ALTER TABLE [dbo].[OfferteArticoliXColonne] CHECK CONSTRAINT [FK_OfferteArticoliXColonne_OfferteArticoli]
GO
ALTER TABLE [dbo].[OfferteArticoliXColonne]  WITH CHECK ADD  CONSTRAINT [FK_OfferteArticoliXColonne_ValoriAttributi] FOREIGN KEY([oacIdVat])
REFERENCES [dbo].[ValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[OfferteArticoliXColonne] CHECK CONSTRAINT [FK_OfferteArticoliXColonne_ValoriAttributi]
GO
