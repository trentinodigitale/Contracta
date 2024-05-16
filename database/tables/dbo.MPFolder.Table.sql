USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPFolder]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPFolder](
	[IdMpf] [int] IDENTITY(1,1) NOT NULL,
	[mpfIdMp] [int] NOT NULL,
	[mpfIType] [smallint] NOT NULL,
	[mpfSubType] [smallint] NULL,
	[mpfIdMultilng] [char](101) NOT NULL,
	[mpfSource] [varchar](50) NOT NULL,
	[mpfCreateSubFolder] [tinyint] NOT NULL,
	[mpfHidden] [bit] NOT NULL,
	[mpfFnzuPos] [int] NOT NULL,
	[mpfFunzionalita] [varchar](10) NULL,
	[mpfDeleted] [bit] NOT NULL,
	[mpfUltimaMod] [datetime] NOT NULL,
	[mpfIcona] [varchar](30) NULL,
	[mpfUse] [varchar](10) NOT NULL,
	[mpfIdGrp] [int] NULL,
	[mpfClauseSql] [varchar](1000) NULL,
 CONSTRAINT [PK_MPFolder] PRIMARY KEY NONCLUSTERED 
(
	[IdMpf] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MPFolder] ADD  CONSTRAINT [DF_MPFolder_mpfCreateSubFolder]  DEFAULT (0) FOR [mpfCreateSubFolder]
GO
ALTER TABLE [dbo].[MPFolder] ADD  CONSTRAINT [DF_MPFolder_mpfHidden]  DEFAULT (0) FOR [mpfHidden]
GO
ALTER TABLE [dbo].[MPFolder] ADD  CONSTRAINT [DF_MPFolder_mpfDeleted]  DEFAULT (0) FOR [mpfDeleted]
GO
ALTER TABLE [dbo].[MPFolder] ADD  CONSTRAINT [DF_MPFolder_mpfUltimaMod]  DEFAULT (getdate()) FOR [mpfUltimaMod]
GO
ALTER TABLE [dbo].[MPFolder] ADD  CONSTRAINT [DF__MPFolder__mpfUse__76C185B7]  DEFAULT ('') FOR [mpfUse]
GO
