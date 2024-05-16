USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempValoriAttributi]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempValoriAttributi](
	[IdVat] [int] NOT NULL,
	[vatTipoMem] [tinyint] NOT NULL,
	[vatIdUms] [int] NULL,
	[vatIdDzt] [int] NOT NULL,
	[vatUltimaMod] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempValoriAttributi] ADD  CONSTRAINT [DF_TempValoriAttributi_vatTipoMem]  DEFAULT (0) FOR [vatTipoMem]
GO
ALTER TABLE [dbo].[TempValoriAttributi] ADD  CONSTRAINT [DF_TempValoriAttributi_vatUltimaMod]  DEFAULT (getdate()) FOR [vatUltimaMod]
GO
