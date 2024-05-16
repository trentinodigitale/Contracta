USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempValoriAttributi_Datetime]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempValoriAttributi_Datetime](
	[IdVat] [int] NOT NULL,
	[vatValore] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempValoriAttributi_Datetime] ADD  CONSTRAINT [DF_TempValoriAttributi_Datetime_vatValore]  DEFAULT (null) FOR [vatValore]
GO
