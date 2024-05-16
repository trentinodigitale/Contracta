USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[RegDefault]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegDefault](
	[IdRd] [int] IDENTITY(1,1) NOT NULL,
	[rdIdMp] [int] NOT NULL,
	[rdPath] [varchar](100) NOT NULL,
	[rdKey] [varchar](50) NOT NULL,
	[rdDefValue] [varchar](2000) NOT NULL,
	[rdDeleted] [bit] NOT NULL,
	[rdUltimaMod] [datetime] NOT NULL,
	[rdiType] [smallint] NOT NULL,
	[rdiSubType] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RegDefault] ADD  CONSTRAINT [DF_RegDefault_rdPath]  DEFAULT ('Software\Sintel\BiztoB\Options\User') FOR [rdPath]
GO
ALTER TABLE [dbo].[RegDefault] ADD  CONSTRAINT [DF_RegDefault_rdDeleted]  DEFAULT (0) FOR [rdDeleted]
GO
ALTER TABLE [dbo].[RegDefault] ADD  CONSTRAINT [DF_RegDefault_rdUltimaMod]  DEFAULT (getdate()) FOR [rdUltimaMod]
GO
ALTER TABLE [dbo].[RegDefault] ADD  CONSTRAINT [DF_RegDefault_rdiType]  DEFAULT ((-1)) FOR [rdiType]
GO
ALTER TABLE [dbo].[RegDefault] ADD  CONSTRAINT [DF_RegDefault_rdiSubType]  DEFAULT ((-1)) FOR [rdiSubType]
GO
