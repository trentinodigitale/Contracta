USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[FolderDocuments]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FolderDocuments](
	[fdIdPf] [int] NOT NULL,
	[fdIdMsg] [int] NOT NULL,
	[fdIdPfu] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FolderDocuments]  WITH CHECK ADD  CONSTRAINT [FK_FolderDocuments_PublicFolders] FOREIGN KEY([fdIdPf])
REFERENCES [dbo].[PublicFolders] ([IdPf])
GO
ALTER TABLE [dbo].[FolderDocuments] CHECK CONSTRAINT [FK_FolderDocuments_PublicFolders]
GO
ALTER TABLE [dbo].[FolderDocuments]  WITH CHECK ADD  CONSTRAINT [FK_FolderDocuments_TAB_MESSAGGI] FOREIGN KEY([fdIdMsg])
REFERENCES [dbo].[TAB_MESSAGGI] ([IdMsg])
GO
ALTER TABLE [dbo].[FolderDocuments] CHECK CONSTRAINT [FK_FolderDocuments_TAB_MESSAGGI]
GO
