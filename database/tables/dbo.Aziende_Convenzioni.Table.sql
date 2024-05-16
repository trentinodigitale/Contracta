USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Aziende_Convenzioni]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Aziende_Convenzioni](
	[IdAzi] [int] NOT NULL,
	[IdCnv] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Aziende_Convenzioni]  WITH NOCHECK ADD  CONSTRAINT [FK_Aziende_Convenzioni_Aziende] FOREIGN KEY([IdAzi])
REFERENCES [dbo].[Aziende] ([IdAzi])
GO
ALTER TABLE [dbo].[Aziende_Convenzioni] CHECK CONSTRAINT [FK_Aziende_Convenzioni_Aziende]
GO
