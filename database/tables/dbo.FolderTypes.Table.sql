USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[FolderTypes]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FolderTypes](
	[IdFt] [int] IDENTITY(1,1) NOT NULL,
	[ftIdPf] [int] NOT NULL,
	[ftIdDcm] [int] NOT NULL,
	[ftUltimaMod] [datetime] NOT NULL,
	[ftDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_FolderTypes] PRIMARY KEY CLUSTERED 
(
	[IdFt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FolderTypes] ADD  CONSTRAINT [DF_FolderTypes_ftUltimaMod]  DEFAULT (getdate()) FOR [ftUltimaMod]
GO
ALTER TABLE [dbo].[FolderTypes] ADD  CONSTRAINT [DF_FolderTypes_ftDeleted]  DEFAULT (0) FOR [ftDeleted]
GO
ALTER TABLE [dbo].[FolderTypes]  WITH CHECK ADD  CONSTRAINT [FK_FolderTypes_PublicFolders] FOREIGN KEY([ftIdPf])
REFERENCES [dbo].[PublicFolders] ([IdPf])
GO
ALTER TABLE [dbo].[FolderTypes] CHECK CONSTRAINT [FK_FolderTypes_PublicFolders]
GO
