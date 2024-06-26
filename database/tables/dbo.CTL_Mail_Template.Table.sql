USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Mail_Template]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Mail_Template](
	[id] [int] NOT NULL,
	[ML_KEY] [nvarchar](255) NULL,
	[ML_KEY_OGGETTO] [nvarchar](255) NULL,
	[Titolo] [varchar](255) NULL,
	[Descrizione] [nvarchar](4000) NULL,
	[DataUltimaMod] [datetime] NULL,
	[ViewName] [varchar](4000) NULL,
	[Multi_Doc] [varchar](2000) NULL,
	[deleted] [int] NULL,
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[MP] [varchar](20) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_Mail_Template] ADD  CONSTRAINT [DF_CTL_Mail_Template_DataUltimaMod]  DEFAULT (getdate()) FOR [DataUltimaMod]
GO
ALTER TABLE [dbo].[CTL_Mail_Template] ADD  CONSTRAINT [DF_CTL_Mail_Template_deleted]  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[CTL_Mail_Template] ADD  DEFAULT ('PA') FOR [MP]
GO
