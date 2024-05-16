USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_sqlobj_owner]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_sqlobj_owner](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[campoOwner] [varchar](200) NULL,
	[oggettoSql] [varchar](200) NOT NULL,
	[bDeleted] [bit] NULL,
	[origine] [varchar](10) NOT NULL,
	[opzionale] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_sqlobj_owner] ADD  CONSTRAINT [DF_CTL_sqlobj_owner_bDeleted]  DEFAULT (0) FOR [bDeleted]
GO
ALTER TABLE [dbo].[CTL_sqlobj_owner] ADD  CONSTRAINT [DF_CTL_sqlobj_owner_origine]  DEFAULT ('js') FOR [origine]
GO
ALTER TABLE [dbo].[CTL_sqlobj_owner] ADD  CONSTRAINT [DF_CTL_sqlobj_owner_opzionale]  DEFAULT (0) FOR [opzionale]
GO
