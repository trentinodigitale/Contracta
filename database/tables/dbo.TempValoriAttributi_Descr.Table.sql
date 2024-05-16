USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempValoriAttributi_Descr]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempValoriAttributi_Descr](
	[IdVat] [int] NOT NULL,
	[vatIdDsc] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempValoriAttributi_Descr] ADD  CONSTRAINT [DF_TempValoriAttributi_Descr_vatIdDsc]  DEFAULT (null) FOR [vatIdDsc]
GO
