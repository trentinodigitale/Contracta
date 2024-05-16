USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[DocumentInfo]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentInfo](
	[IdDi] [int] IDENTITY(1,1) NOT NULL,
	[diIdDcm] [int] NOT NULL,
	[diVersion] [varchar](50) NOT NULL,
	[diAdviseStatusDescrFieldName] [varchar](50) NOT NULL,
	[diLinkFieldName] [varchar](50) NULL,
	[diAdviseStatusValueFieldName] [varchar](50) NOT NULL,
	[diPriorityStatusFieldName] [varchar](50) NOT NULL,
	[diDeleted] [bit] NOT NULL,
	[diUltimaMod] [datetime] NOT NULL,
	[diParentFieldName] [varchar](50) NULL,
	[diLinkFieldNameSource] [varchar](50) NULL,
	[diAttachInitPos] [smallint] NULL,
 CONSTRAINT [PK_DocumentInfo] PRIMARY KEY CLUSTERED 
(
	[IdDi] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DocumentInfo] ADD  CONSTRAINT [DF_DocumentInfo_PriorityStatusFieldName]  DEFAULT ('StatusPriority') FOR [diPriorityStatusFieldName]
GO
ALTER TABLE [dbo].[DocumentInfo] ADD  CONSTRAINT [DF_DocumentInfo_diDeleted]  DEFAULT (0) FOR [diDeleted]
GO
ALTER TABLE [dbo].[DocumentInfo] ADD  CONSTRAINT [DF_DocumentInfo_diUltimaMod]  DEFAULT (getdate()) FOR [diUltimaMod]
GO
