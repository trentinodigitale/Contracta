USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ProfiliUtente_DataLastOperation]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProfiliUtente_DataLastOperation](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdPfu] [int] NOT NULL,
	[Data] [datetime] NULL
) ON [PRIMARY]
GO
