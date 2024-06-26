USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CompanyTab]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyTab](
	[IdCt] [int] IDENTITY(1,1) NOT NULL,
	[ctIdMp] [int] NOT NULL,
	[ctItype] [smallint] NOT NULL,
	[ctIsubtype] [smallint] NOT NULL,
	[ctIdMultiLng] [char](101) NOT NULL,
	[ctProfile] [varchar](20) NOT NULL,
	[ctFnzuPos] [int] NOT NULL,
	[ctOrder] [int] NOT NULL,
	[ctDeleted] [bit] NOT NULL,
	[ctPath] [varchar](1000) NULL,
	[ctUltimaMod] [datetime] NOT NULL,
	[ctParent] [int] NOT NULL,
	[ctTabType] [varchar](10) NOT NULL,
	[ctIdGrp] [int] NULL,
	[ctTabName] [varchar](50) NULL,
	[ctProgId] [varchar](50) NULL,
 CONSTRAINT [PK_CompanyTab] PRIMARY KEY CLUSTERED 
(
	[IdCt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyTab] ADD  CONSTRAINT [DF_CompanyTab_ctDeleted]  DEFAULT (0) FOR [ctDeleted]
GO
ALTER TABLE [dbo].[CompanyTab] ADD  CONSTRAINT [DF__CompanyTa__ctUlt__5FDE205F]  DEFAULT (getdate()) FOR [ctUltimaMod]
GO
ALTER TABLE [dbo].[CompanyTab] ADD  CONSTRAINT [DF__CompanyTa__ctPar__799DF262]  DEFAULT ((-1)) FOR [ctParent]
GO
ALTER TABLE [dbo].[CompanyTab] ADD  CONSTRAINT [DF__CompanyTa__ctTab__7A92169B]  DEFAULT ('') FOR [ctTabType]
GO
