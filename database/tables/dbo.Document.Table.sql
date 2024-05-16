USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document](
	[IdDcm] [int] IDENTITY(1,1) NOT NULL,
	[dcmDescription] [char](101) NOT NULL,
	[dcmIType] [smallint] NOT NULL,
	[dcmIsubType] [smallint] NOT NULL,
	[dcmRelatedIdDcm] [int] NULL,
	[dcmInput] [bit] NOT NULL,
	[dcmDeleted] [tinyint] NOT NULL,
	[dcmUltimaMod] [datetime] NOT NULL,
	[dcmTypeDoc] [tinyint] NOT NULL,
	[dcmStorico] [bit] NOT NULL,
	[dcmDetail] [varchar](10) NULL,
	[dcmSendUnreadAdvise] [bit] NOT NULL,
	[dcmOption] [varchar](20) NOT NULL,
	[dcmIdGrp] [int] NULL,
	[dcmURL] [nvarchar](1000) NULL,
	[dcmISubTypeRef] [smallint] NULL,
	[dcmDocPermission] [varchar](50) NULL,
	[tipodoc] [varchar](500) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document] ADD  CONSTRAINT [DF_Document_dcmInput]  DEFAULT (0) FOR [dcmInput]
GO
ALTER TABLE [dbo].[Document] ADD  CONSTRAINT [DF_Document_dcmDeleted]  DEFAULT (0) FOR [dcmDeleted]
GO
ALTER TABLE [dbo].[Document] ADD  CONSTRAINT [DF_Document_dcmUltimaMod]  DEFAULT (getdate()) FOR [dcmUltimaMod]
GO
ALTER TABLE [dbo].[Document] ADD  CONSTRAINT [DF_Document_dcmTypeDoc]  DEFAULT (0) FOR [dcmTypeDoc]
GO
ALTER TABLE [dbo].[Document] ADD  CONSTRAINT [DF_Document_dcmStorico]  DEFAULT (0) FOR [dcmStorico]
GO
ALTER TABLE [dbo].[Document] ADD  CONSTRAINT [DF_Document_dcmSendUnreadAdvise]  DEFAULT (1) FOR [dcmSendUnreadAdvise]
GO
ALTER TABLE [dbo].[Document] ADD  CONSTRAINT [DF__Document__dcmOpt__78A9CE29]  DEFAULT ('00000000000000000000') FOR [dcmOption]
GO
ALTER TABLE [dbo].[Document] ADD  CONSTRAINT [DF_Document_dcmDocPermission]  DEFAULT ('') FOR [dcmDocPermission]
GO
