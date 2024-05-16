USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Messaggi]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Messaggi](
	[IdMsg] [int] NOT NULL,
	[msgIdDcm] [int] NULL,
	[msgName] [nvarchar](400) NOT NULL,
	[msgProtocol] [nvarchar](100) NULL,
	[msgIdMsgParent] [int] NULL,
	[msgIdCDO] [varchar](100) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Messaggi]  WITH CHECK ADD  CONSTRAINT [FK_Messaggi_Document] FOREIGN KEY([msgIdDcm])
REFERENCES [dbo].[Document] ([IdDcm])
GO
ALTER TABLE [dbo].[Messaggi] CHECK CONSTRAINT [FK_Messaggi_Document]
GO
ALTER TABLE [dbo].[Messaggi]  WITH CHECK ADD  CONSTRAINT [FK_Messaggi_TAB_MESSAGGI] FOREIGN KEY([IdMsg])
REFERENCES [dbo].[TAB_MESSAGGI] ([IdMsg])
GO
ALTER TABLE [dbo].[Messaggi] CHECK CONSTRAINT [FK_Messaggi_TAB_MESSAGGI]
GO
