USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ValoriAttributi_Nvarchar]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ValoriAttributi_Nvarchar](
	[IdVat] [int] NOT NULL,
	[vatValore] [nvarchar](1500) NULL
) ON [PRIMARY]
GO
