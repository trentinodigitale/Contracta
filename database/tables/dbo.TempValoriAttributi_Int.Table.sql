USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempValoriAttributi_Int]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempValoriAttributi_Int](
	[IdVat] [int] NOT NULL,
	[vatValore] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempValoriAttributi_Int] ADD  CONSTRAINT [DF_TempValoriAttributi_Int_vatValore]  DEFAULT (null) FOR [vatValore]
GO
