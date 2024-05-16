USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[DfVatAzi]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DfVatAzi](
	[IdVat] [int] NOT NULL,
	[IdAzi] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DfVatAzi]  WITH NOCHECK ADD  CONSTRAINT [FK_DfVatAzi_Aziende] FOREIGN KEY([IdAzi])
REFERENCES [dbo].[Aziende] ([IdAzi])
GO
ALTER TABLE [dbo].[DfVatAzi] CHECK CONSTRAINT [FK_DfVatAzi_Aziende]
GO
ALTER TABLE [dbo].[DfVatAzi]  WITH CHECK ADD  CONSTRAINT [FK_DfVatAzi_ValoriAttributi] FOREIGN KEY([IdVat])
REFERENCES [dbo].[ValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[DfVatAzi] CHECK CONSTRAINT [FK_DfVatAzi_ValoriAttributi]
GO
