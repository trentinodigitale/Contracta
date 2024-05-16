USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[GeneratedDocument]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GeneratedDocument](
	[IdGd] [int] IDENTITY(1,1) NOT NULL,
	[gdIdDcmSource] [int] NOT NULL,
	[gdIdDcmTarget] [int] NOT NULL,
	[gdUltimaMod] [datetime] NOT NULL,
	[gdDeleted] [bit] NOT NULL,
	[gdTypeGen] [varchar](5) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GeneratedDocument] ADD  CONSTRAINT [DF__Generated__gdUlt__74D93D45]  DEFAULT (getdate()) FOR [gdUltimaMod]
GO
ALTER TABLE [dbo].[GeneratedDocument] ADD  CONSTRAINT [DF__Generated__gdDel__75CD617E]  DEFAULT (0) FOR [gdDeleted]
GO
ALTER TABLE [dbo].[GeneratedDocument] ADD  CONSTRAINT [DF__Generated__gdTyp__041B80D5]  DEFAULT ('S') FOR [gdTypeGen]
GO
