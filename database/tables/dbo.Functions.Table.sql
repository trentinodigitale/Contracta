USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Functions]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Functions](
	[IdFnc] [int] IDENTITY(1,1) NOT NULL,
	[fncIdGrp] [int] NOT NULL,
	[fncLocation] [varchar](10) NULL,
	[fncName] [varchar](200) NULL,
	[fncCaption] [char](101) NOT NULL,
	[fncIcon] [varchar](30) NULL,
	[fncUserFunz] [int] NULL,
	[fncUse] [varchar](10) NOT NULL,
	[fncHide] [bit] NOT NULL,
	[fncCommand] [varchar](100) NULL,
	[fncParam] [varchar](8000) NULL,
	[fncCondition] [varchar](1000) NULL,
	[fncOrder] [int] NOT NULL,
	[fncUltimaMod] [datetime] NOT NULL,
	[fncDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_Functions] PRIMARY KEY CLUSTERED 
(
	[IdFnc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Functions] ADD  CONSTRAINT [DF__Functions__fncUs__6D381B7D]  DEFAULT (0) FOR [fncUserFunz]
GO
ALTER TABLE [dbo].[Functions] ADD  CONSTRAINT [DF__Functions__fncHi__6E2C3FB6]  DEFAULT (0) FOR [fncHide]
GO
ALTER TABLE [dbo].[Functions] ADD  CONSTRAINT [DF__Functions__fncOr__6F2063EF]  DEFAULT (1) FOR [fncOrder]
GO
ALTER TABLE [dbo].[Functions] ADD  CONSTRAINT [DF__Functions__fncUl__70148828]  DEFAULT (getdate()) FOR [fncUltimaMod]
GO
ALTER TABLE [dbo].[Functions] ADD  CONSTRAINT [DF__Functions__fncDe__7108AC61]  DEFAULT (0) FOR [fncDeleted]
GO
ALTER TABLE [dbo].[Functions]  WITH NOCHECK ADD  CONSTRAINT [FK_Functions_FunctionsGroups] FOREIGN KEY([fncIdGrp])
REFERENCES [dbo].[FunctionsGroups] ([IdGrp])
GO
ALTER TABLE [dbo].[Functions] CHECK CONSTRAINT [FK_Functions_FunctionsGroups]
GO
