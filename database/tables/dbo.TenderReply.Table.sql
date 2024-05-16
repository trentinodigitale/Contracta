USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TenderReply]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TenderReply](
	[IdMsg] [int] NOT NULL,
	[IdTender] [int] NOT NULL,
	[trStatus] [tinyint] NOT NULL,
	[trOpenTab] [varchar](20) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TenderReply] ADD  CONSTRAINT [DF__TenderRep__trOpe__03275C9C]  DEFAULT ('00000000000000000000') FOR [trOpenTab]
GO
