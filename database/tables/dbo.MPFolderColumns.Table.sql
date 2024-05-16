USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPFolderColumns]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPFolderColumns](
	[Idmpfc] [int] IDENTITY(1,1) NOT NULL,
	[mpfcIdMp] [int] NOT NULL,
	[mpfcIType] [smallint] NOT NULL,
	[mpfcISubType] [smallint] NOT NULL,
	[mpfcCaption] [char](101) NOT NULL,
	[mpfcTypeCaption] [tinyint] NOT NULL,
	[mpfcTypeCol] [tinyint] NOT NULL,
	[mpfcTypeEdit] [tinyint] NOT NULL,
	[mpfcFieldName] [varchar](50) NOT NULL,
	[mpfcColWidth] [smallint] NOT NULL,
	[mpfcSortType] [tinyint] NOT NULL,
	[mpfcKeyIcon] [varchar](30) NOT NULL,
	[mpfcVisible] [tinyint] NOT NULL,
	[mpfcOrder] [smallint] NOT NULL,
	[mpfcContext] [tinyint] NOT NULL,
	[mpfcNullBehaviour] [tinyint] NOT NULL,
	[mpfcDeleted] [bit] NOT NULL,
	[mpfcUltimaMod] [datetime] NOT NULL,
	[mpfcUse] [varchar](10) NOT NULL,
	[mpfcCommand] [varchar](50) NULL,
	[mpfcParam] [varchar](50) NULL,
	[mpfcTooltip] [varchar](50) NULL,
 CONSTRAINT [PK_MPFolderCommands] PRIMARY KEY NONCLUSTERED 
(
	[Idmpfc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MPFolderColumns] ADD  CONSTRAINT [DF_MPFolderCommands_mpfcCaption]  DEFAULT ('') FOR [mpfcCaption]
GO
ALTER TABLE [dbo].[MPFolderColumns] ADD  CONSTRAINT [DF_MPFolderCommands_mpfcDeleted]  DEFAULT (0) FOR [mpfcDeleted]
GO
ALTER TABLE [dbo].[MPFolderColumns] ADD  CONSTRAINT [DF_MPFolderCommands_mpfcUltimaMod]  DEFAULT (getdate()) FOR [mpfcUltimaMod]
GO
ALTER TABLE [dbo].[MPFolderColumns] ADD  CONSTRAINT [DF__MPFolderC__mpfcU__77B5A9F0]  DEFAULT ('') FOR [mpfcUse]
GO
