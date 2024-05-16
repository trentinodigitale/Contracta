USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MSGValoriAttributi_Money]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MSGValoriAttributi_Money](
	[IdVat] [int] NOT NULL,
	[vatValore] [money] NOT NULL,
	[vatIdSdv] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MSGValoriAttributi_Money] ADD  CONSTRAINT [DF_MSGValoriAttributi_Money_vatIdSdv]  DEFAULT (1) FOR [vatIdSdv]
GO
ALTER TABLE [dbo].[MSGValoriAttributi_Money]  WITH CHECK ADD  CONSTRAINT [FK_MSGValoriAttributi_Money_MSGValoriAttributi] FOREIGN KEY([IdVat])
REFERENCES [dbo].[MSGValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[MSGValoriAttributi_Money] CHECK CONSTRAINT [FK_MSGValoriAttributi_Money_MSGValoriAttributi]
GO
