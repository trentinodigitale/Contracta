USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TabPrefissoProtocollo]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TabPrefissoProtocollo](
	[IdAzi] [int] NOT NULL,
	[PrefissoProt] [nvarchar](3) NOT NULL,
	[Contatore] [int] NOT NULL
) ON [PRIMARY]
GO
