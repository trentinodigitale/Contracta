USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[FunctionsGroups]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FunctionsGroups](
	[IdGrp] [int] IDENTITY(1,1) NOT NULL,
	[grpName] [char](101) NOT NULL,
	[grpUltimaMod] [datetime] NOT NULL,
	[grpDeleted] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FunctionsGroups] ADD  CONSTRAINT [DF__Functions__grpUl__6A5BAED2]  DEFAULT (getdate()) FOR [grpUltimaMod]
GO
ALTER TABLE [dbo].[FunctionsGroups] ADD  CONSTRAINT [DF__Functions__grpDe__6B4FD30B]  DEFAULT (0) FOR [grpDeleted]
GO
