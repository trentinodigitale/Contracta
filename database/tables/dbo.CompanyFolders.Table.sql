USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CompanyFolders]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyFolders](
	[cfIdGrp] [int] NOT NULL,
	[cfIdAzi] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyFolders]  WITH NOCHECK ADD  CONSTRAINT [FK_CompanyFolders_Aziende] FOREIGN KEY([cfIdAzi])
REFERENCES [dbo].[Aziende] ([IdAzi])
GO
ALTER TABLE [dbo].[CompanyFolders] CHECK CONSTRAINT [FK_CompanyFolders_Aziende]
GO
