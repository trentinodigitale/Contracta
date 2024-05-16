USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MSGValoriAttributi_Nvarchar]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MSGValoriAttributi_Nvarchar](
	[IdVat] [int] NOT NULL,
	[vatValore] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MSGValoriAttributi_Nvarchar]  WITH CHECK ADD  CONSTRAINT [FK_MSGValoriAttributi_Nvarchar_MSGValoriAttributi] FOREIGN KEY([IdVat])
REFERENCES [dbo].[MSGValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[MSGValoriAttributi_Nvarchar] CHECK CONSTRAINT [FK_MSGValoriAttributi_Nvarchar_MSGValoriAttributi]
GO
