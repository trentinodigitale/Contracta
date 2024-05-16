USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempValoriAttributi_Nvarchar]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempValoriAttributi_Nvarchar](
	[IdVat] [int] NOT NULL,
	[vatValore] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempValoriAttributi_Nvarchar] ADD  CONSTRAINT [DF_TempValoriAttributi_Nvarchar_vatValore]  DEFAULT (null) FOR [vatValore]
GO
