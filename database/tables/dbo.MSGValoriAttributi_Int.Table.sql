USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MSGValoriAttributi_Int]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MSGValoriAttributi_Int](
	[IdVat] [int] NOT NULL,
	[vatValore] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MSGValoriAttributi_Int]  WITH CHECK ADD  CONSTRAINT [FK_MSGValoriAttributi_Int_MSGValoriAttributi] FOREIGN KEY([IdVat])
REFERENCES [dbo].[MSGValoriAttributi] ([IdVat])
GO
ALTER TABLE [dbo].[MSGValoriAttributi_Int] CHECK CONSTRAINT [FK_MSGValoriAttributi_Int_MSGValoriAttributi]
GO
