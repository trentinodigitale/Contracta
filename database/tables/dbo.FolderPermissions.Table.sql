USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[FolderPermissions]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FolderPermissions](
	[fpIdPf] [int] NOT NULL,
	[fpIdPfu] [int] NOT NULL,
	[fpPrm] [varchar](20) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FolderPermissions]  WITH CHECK ADD  CONSTRAINT [FK_FolderPermissions_PublicFolders] FOREIGN KEY([fpIdPf])
REFERENCES [dbo].[PublicFolders] ([IdPf])
GO
ALTER TABLE [dbo].[FolderPermissions] CHECK CONSTRAINT [FK_FolderPermissions_PublicFolders]
GO
