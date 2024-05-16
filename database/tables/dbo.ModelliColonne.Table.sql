USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ModelliColonne]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ModelliColonne](
	[IdMcl] [int] IDENTITY(1,1) NOT NULL,
	[mclIdMdl] [int] NOT NULL,
	[mclIdVatDefault] [int] NOT NULL,
	[mclIdDzt] [int] NOT NULL,
	[mclModificabile] [bit] NOT NULL,
	[mclShadow] [bit] NOT NULL,
	[mclPosizione] [tinyint] NOT NULL,
	[mclAllDefault] [int] NOT NULL,
	[mclPesoFvaDefault] [tinyint] NULL,
	[mclIdFvaDefault] [int] NULL,
 CONSTRAINT [PK_ModelliColonne] PRIMARY KEY NONCLUSTERED 
(
	[IdMcl] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModelliColonne] ADD  CONSTRAINT [DF_ModelliColonne_mclShadow]  DEFAULT (0) FOR [mclShadow]
GO
ALTER TABLE [dbo].[ModelliColonne] ADD  CONSTRAINT [DF_ModelliColonne_mclAllDefault]  DEFAULT (1) FOR [mclAllDefault]
GO
ALTER TABLE [dbo].[ModelliColonne]  WITH CHECK ADD  CONSTRAINT [FK_ModelliColonne_DizionarioAttributi] FOREIGN KEY([mclIdDzt])
REFERENCES [dbo].[DizionarioAttributi] ([IdDzt])
GO
ALTER TABLE [dbo].[ModelliColonne] CHECK CONSTRAINT [FK_ModelliColonne_DizionarioAttributi]
GO
ALTER TABLE [dbo].[ModelliColonne]  WITH CHECK ADD  CONSTRAINT [FK_ModelliColonne_FunzioniValutazione] FOREIGN KEY([mclIdFvaDefault])
REFERENCES [dbo].[FunzioniValutazione] ([IdFva])
GO
ALTER TABLE [dbo].[ModelliColonne] CHECK CONSTRAINT [FK_ModelliColonne_FunzioniValutazione]
GO
ALTER TABLE [dbo].[ModelliColonne]  WITH CHECK ADD  CONSTRAINT [FK_ModelliColonne_Modelli] FOREIGN KEY([mclIdMdl])
REFERENCES [dbo].[Modelli] ([IdMdl])
GO
ALTER TABLE [dbo].[ModelliColonne] CHECK CONSTRAINT [FK_ModelliColonne_Modelli]
GO
ALTER TABLE [dbo].[ModelliColonne]  WITH CHECK ADD  CONSTRAINT [FK_ModelliColonne_ValoriAttributi] FOREIGN KEY([mclIdVatDefault])
REFERENCES [dbo].[ValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[ModelliColonne] CHECK CONSTRAINT [FK_ModelliColonne_ValoriAttributi]
GO
