USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_DATI_CIFRATI]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_DATI_CIFRATI](
	[KEY_ROW] [nvarchar](400) NULL,
	[row] [int] NULL,
	[Dati] [varbinary](8000) NULL
) ON [PRIMARY]
GO
