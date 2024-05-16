USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempValoriAttributi_Float]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempValoriAttributi_Float](
	[IdVat] [int] NOT NULL,
	[vatValore] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempValoriAttributi_Float] ADD  CONSTRAINT [DF_TempValoriAttributi_Float_vatValore]  DEFAULT (null) FOR [vatValore]
GO
