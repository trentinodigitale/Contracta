USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[AttrVisualProp]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AttrVisualProp](
	[IdAvp] [int] IDENTITY(1,1) NOT NULL,
	[avpIdMp] [int] NOT NULL,
	[avpContext] [varchar](50) NOT NULL,
	[avpIdDzt] [int] NOT NULL,
	[avpValue] [int] NOT NULL,
	[avpIdDztCrt] [int] NOT NULL,
	[avpUltimaMod] [datetime] NOT NULL,
	[avpDeleted] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AttrVisualProp] ADD  CONSTRAINT [DF_AttrVisualProp_avpUltimaMod]  DEFAULT (getdate()) FOR [avpUltimaMod]
GO
ALTER TABLE [dbo].[AttrVisualProp] ADD  CONSTRAINT [DF_AttrVisualProp_avpDeleted]  DEFAULT (0) FOR [avpDeleted]
GO
