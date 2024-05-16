USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ModelliAllegati]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ModelliAllegati](
	[magIdMdl] [int] NOT NULL,
	[magIdMgr] [int] NOT NULL,
	[magNome] [nvarchar](20) NOT NULL,
	[magAllegato] [image] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModelliAllegati]  WITH CHECK ADD  CONSTRAINT [FK_ModelliAllegati_Modelli] FOREIGN KEY([magIdMdl])
REFERENCES [dbo].[Modelli] ([IdMdl])
GO
ALTER TABLE [dbo].[ModelliAllegati] CHECK CONSTRAINT [FK_ModelliAllegati_Modelli]
GO
ALTER TABLE [dbo].[ModelliAllegati]  WITH CHECK ADD  CONSTRAINT [FK_ModelliAllegati_ModelliGruppi] FOREIGN KEY([magIdMgr])
REFERENCES [dbo].[ModelliGruppi] ([IdMgr])
GO
ALTER TABLE [dbo].[ModelliAllegati] CHECK CONSTRAINT [FK_ModelliAllegati_ModelliGruppi]
GO
