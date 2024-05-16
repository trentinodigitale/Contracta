USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MessageFields]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MessageFields](
	[mfIdMsg] [int] NOT NULL,
	[mfIType] [smallint] NOT NULL,
	[mfIsubType] [smallint] NOT NULL,
	[mfFieldName] [varchar](80) NOT NULL,
	[mfFieldValue] [varchar](100) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageFields]  WITH CHECK ADD  CONSTRAINT [FK_MessageFields_TAB_MESSAGGI] FOREIGN KEY([mfIdMsg])
REFERENCES [dbo].[TAB_MESSAGGI] ([IdMsg])
GO
ALTER TABLE [dbo].[MessageFields] CHECK CONSTRAINT [FK_MessageFields_TAB_MESSAGGI]
GO
