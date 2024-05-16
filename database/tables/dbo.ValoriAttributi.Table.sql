USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ValoriAttributi]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ValoriAttributi](
	[IdVat] [int] IDENTITY(1,1) NOT NULL,
	[vatTipoMem] [tinyint] NOT NULL,
	[vatIdUms] [int] NULL,
	[vatIdDzt] [int] NOT NULL,
	[vatUltimaMod] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ValoriAttributi] ADD  CONSTRAINT [DF_ValoriAttributi_vatTipoMem]  DEFAULT (0) FOR [vatTipoMem]
GO
ALTER TABLE [dbo].[ValoriAttributi] ADD  CONSTRAINT [DF_ValoriAttributi_vatUltimaMod]  DEFAULT (getdate()) FOR [vatUltimaMod]
GO
ALTER TABLE [dbo].[ValoriAttributi]  WITH CHECK ADD  CONSTRAINT [FK_AttributoValorizzato] FOREIGN KEY([vatIdDzt])
REFERENCES [dbo].[DizionarioAttributi] ([IdDzt])
GO
ALTER TABLE [dbo].[ValoriAttributi] CHECK CONSTRAINT [FK_AttributoValorizzato]
GO
