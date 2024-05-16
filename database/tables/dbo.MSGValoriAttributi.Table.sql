USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MSGValoriAttributi]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MSGValoriAttributi](
	[IdVat] [int] IDENTITY(1,1) NOT NULL,
	[vatTipoMem] [tinyint] NOT NULL,
	[vatIdUms] [int] NULL,
	[vatIdDzt] [int] NOT NULL,
	[vatUltimaMod] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MSGValoriAttributi]  WITH CHECK ADD  CONSTRAINT [FK_MSGValoriAttributi_DizionarioAttributi] FOREIGN KEY([vatIdDzt])
REFERENCES [dbo].[DizionarioAttributi] ([IdDzt])
GO
ALTER TABLE [dbo].[MSGValoriAttributi] CHECK CONSTRAINT [FK_MSGValoriAttributi_DizionarioAttributi]
GO
ALTER TABLE [dbo].[MSGValoriAttributi]  WITH CHECK ADD  CONSTRAINT [FK_MSGValoriAttributi_UnitaMisura] FOREIGN KEY([vatIdUms])
REFERENCES [dbo].[UnitaMisura] ([IdUms])
GO
ALTER TABLE [dbo].[MSGValoriAttributi] CHECK CONSTRAINT [FK_MSGValoriAttributi_UnitaMisura]
GO
