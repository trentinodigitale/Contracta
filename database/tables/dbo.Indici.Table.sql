USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Indici]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Indici](
	[IdInd] [int] IDENTITY(1,1) NOT NULL,
	[indTableName] [varchar](100) NOT NULL,
	[indIndexName] [varchar](100) NOT NULL,
	[indFieldsName] [varchar](500) NOT NULL,
	[indUnique] [bit] NOT NULL,
	[indLanguage] [bit] NOT NULL,
	[indDeleted] [bit] NOT NULL,
	[indUltimaMod] [datetime] NOT NULL,
 CONSTRAINT [PK_Indici] PRIMARY KEY NONCLUSTERED 
(
	[IdInd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Indici] ADD  CONSTRAINT [DF_Indici_imdUnique]  DEFAULT (0) FOR [indUnique]
GO
ALTER TABLE [dbo].[Indici] ADD  CONSTRAINT [DF_Indici_indLanguage]  DEFAULT (0) FOR [indLanguage]
GO
ALTER TABLE [dbo].[Indici] ADD  CONSTRAINT [DF_Indici_indDeleted]  DEFAULT (0) FOR [indDeleted]
GO
ALTER TABLE [dbo].[Indici] ADD  CONSTRAINT [DF_Indici_indUltimaMod]  DEFAULT (getdate()) FOR [indUltimaMod]
GO
