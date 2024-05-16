USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempValoriAttributi_Keys]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempValoriAttributi_Keys](
	[IdVat] [int] NOT NULL,
	[vatValore] [int] NULL,
	[vatValoreUp] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempValoriAttributi_Keys] ADD  CONSTRAINT [DF_TempValoriAttributi_Keys_vatValore]  DEFAULT (null) FOR [vatValore]
GO
ALTER TABLE [dbo].[TempValoriAttributi_Keys] ADD  CONSTRAINT [DF_TempValoriAttributi_Keys_vatValoreUp]  DEFAULT (2147483647) FOR [vatValoreUp]
GO
