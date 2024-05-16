USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ModelliArticoliXColonne]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ModelliArticoliXColonne](
	[macIdMar] [int] NOT NULL,
	[macIdMcl] [int] NOT NULL,
	[macIdVat] [int] NOT NULL,
	[macScore] [smallint] NULL,
 CONSTRAINT [UN_ModelliArticoliXColonne] UNIQUE NONCLUSTERED 
(
	[macIdMar] ASC,
	[macIdMcl] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModelliArticoliXColonne]  WITH CHECK ADD  CONSTRAINT [FK_ModelliArticoliXColonne_ModelliArticoli] FOREIGN KEY([macIdMar])
REFERENCES [dbo].[ModelliArticoli] ([IdMar])
GO
ALTER TABLE [dbo].[ModelliArticoliXColonne] CHECK CONSTRAINT [FK_ModelliArticoliXColonne_ModelliArticoli]
GO
ALTER TABLE [dbo].[ModelliArticoliXColonne]  WITH CHECK ADD  CONSTRAINT [FK_ModelliArticoliXColonne_ValoriAttributi] FOREIGN KEY([macIdVat])
REFERENCES [dbo].[ValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[ModelliArticoliXColonne] CHECK CONSTRAINT [FK_ModelliArticoliXColonne_ValoriAttributi]
GO
