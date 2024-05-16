USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TabProps]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TabProps](
	[IdTp] [int] IDENTITY(1,1) NOT NULL,
	[tpIdCt] [int] NULL,
	[tpItypeSource] [smallint] NOT NULL,
	[tpISubTypeSource] [smallint] NOT NULL,
	[tpAttrib] [varchar](500) NOT NULL,
	[tpValue] [varchar](500) NOT NULL,
	[tpUltimaMod] [datetime] NOT NULL,
	[tpDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_TabProps] PRIMARY KEY CLUSTERED 
(
	[IdTp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TabProps] ADD  CONSTRAINT [DF_TabProps_tpItypeSource]  DEFAULT (0) FOR [tpItypeSource]
GO
ALTER TABLE [dbo].[TabProps] ADD  CONSTRAINT [DF_TabProps_tpISubTypeSource]  DEFAULT (0) FOR [tpISubTypeSource]
GO
ALTER TABLE [dbo].[TabProps] ADD  CONSTRAINT [DF_TabProps_tpUltimaMod]  DEFAULT (getdate()) FOR [tpUltimaMod]
GO
ALTER TABLE [dbo].[TabProps] ADD  CONSTRAINT [DF_TabProps_tpDeleted]  DEFAULT (0) FOR [tpDeleted]
GO
