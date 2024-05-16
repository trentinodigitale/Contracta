USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempValoriAttributi_Money]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempValoriAttributi_Money](
	[IdVat] [int] NOT NULL,
	[vatValore] [money] NULL,
	[vatIdSdv] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempValoriAttributi_Money] ADD  CONSTRAINT [DF_TempValoriAttributi_Money_vatValore]  DEFAULT (null) FOR [vatValore]
GO
ALTER TABLE [dbo].[TempValoriAttributi_Money] ADD  CONSTRAINT [DF_TempValoriAttributi_Money_vatIdSdv]  DEFAULT (1) FOR [vatIdSdv]
GO
