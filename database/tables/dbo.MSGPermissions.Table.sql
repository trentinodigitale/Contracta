USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MSGPermissions]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MSGPermissions](
	[mpIdMsg] [int] NOT NULL,
	[mpIdPfu] [int] NOT NULL,
	[mpRead] [bit] NOT NULL,
	[mpWrite] [bit] NOT NULL,
	[mpUpdate] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MSGPermissions] ADD  CONSTRAINT [DF_MSGPermissions_mpRead]  DEFAULT (0) FOR [mpRead]
GO
ALTER TABLE [dbo].[MSGPermissions] ADD  CONSTRAINT [DF_MSGPermissions_mpWrite]  DEFAULT (0) FOR [mpWrite]
GO
ALTER TABLE [dbo].[MSGPermissions] ADD  CONSTRAINT [DF_MSGPermissions_mpUpdate]  DEFAULT (0) FOR [mpUpdate]
GO
ALTER TABLE [dbo].[MSGPermissions]  WITH CHECK ADD  CONSTRAINT [FK_MSGPermissions_ProfiliUtente] FOREIGN KEY([mpIdPfu])
REFERENCES [dbo].[ProfiliUtente] ([IdPfu])
GO
ALTER TABLE [dbo].[MSGPermissions] CHECK CONSTRAINT [FK_MSGPermissions_ProfiliUtente]
GO
ALTER TABLE [dbo].[MSGPermissions]  WITH CHECK ADD  CONSTRAINT [FK_MSGPermissions_TAB_MESSAGGI] FOREIGN KEY([mpIdMsg])
REFERENCES [dbo].[TAB_MESSAGGI] ([IdMsg])
GO
ALTER TABLE [dbo].[MSGPermissions] CHECK CONSTRAINT [FK_MSGPermissions_TAB_MESSAGGI]
GO
