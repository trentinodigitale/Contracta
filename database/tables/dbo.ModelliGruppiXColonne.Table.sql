USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ModelliGruppiXColonne]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ModelliGruppiXColonne](
	[mgcIdMgr] [int] NOT NULL,
	[mgcIdMcl] [int] NOT NULL,
	[mgcPesoFva] [tinyint] NULL,
	[mgcIdFva] [int] NULL,
	[mgcIdVatDefault] [int] NULL,
 CONSTRAINT [UN_ModelliGruppiXColonne] UNIQUE NONCLUSTERED 
(
	[mgcIdMgr] ASC,
	[mgcIdMcl] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModelliGruppiXColonne]  WITH CHECK ADD  CONSTRAINT [FK_ModelliGruppiXColonne_FunzioniValutazione] FOREIGN KEY([mgcIdFva])
REFERENCES [dbo].[FunzioniValutazione] ([IdFva])
GO
ALTER TABLE [dbo].[ModelliGruppiXColonne] CHECK CONSTRAINT [FK_ModelliGruppiXColonne_FunzioniValutazione]
GO
ALTER TABLE [dbo].[ModelliGruppiXColonne]  WITH CHECK ADD  CONSTRAINT [FK_ModelliGruppiXColonne_ModelliGruppi] FOREIGN KEY([mgcIdMgr])
REFERENCES [dbo].[ModelliGruppi] ([IdMgr])
GO
ALTER TABLE [dbo].[ModelliGruppiXColonne] CHECK CONSTRAINT [FK_ModelliGruppiXColonne_ModelliGruppi]
GO
ALTER TABLE [dbo].[ModelliGruppiXColonne]  WITH CHECK ADD  CONSTRAINT [FK_ModelliGruppiXColonne_ValoriAttributi] FOREIGN KEY([mgcIdVatDefault])
REFERENCES [dbo].[ValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[ModelliGruppiXColonne] CHECK CONSTRAINT [FK_ModelliGruppiXColonne_ValoriAttributi]
GO
