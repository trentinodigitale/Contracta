USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPGroups]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPGroups](
	[IdMpg] [int] IDENTITY(1,1) NOT NULL,
	[mpgIdMp] [int] NOT NULL,
	[mpgIdGroup] [int] NOT NULL,
	[mpgGroupKey] [varchar](50) NOT NULL,
	[mpgGroupName] [char](101) NOT NULL,
	[mpgUserProfile] [varchar](20) NOT NULL,
	[mpgGroupType] [smallint] NOT NULL,
	[mpgOrdine] [smallint] NOT NULL,
	[mpgDeleted] [bit] NOT NULL,
	[mpgUltimaMod] [datetime] NOT NULL,
 CONSTRAINT [PK_MPGroups] PRIMARY KEY NONCLUSTERED 
(
	[IdMpg] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MPGroups] ADD  CONSTRAINT [DF_MPGroups_mpgDeleted]  DEFAULT (0) FOR [mpgDeleted]
GO
ALTER TABLE [dbo].[MPGroups] ADD  CONSTRAINT [DF_MPGroups_mpgUltimaMod]  DEFAULT (getdate()) FOR [mpgUltimaMod]
GO
