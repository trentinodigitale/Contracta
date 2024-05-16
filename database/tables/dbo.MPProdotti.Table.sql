USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPProdotti]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPProdotti](
	[IdMpp] [int] IDENTITY(1,1) NOT NULL,
	[mppIdProd] [int] NOT NULL,
	[mppIdMp] [int] NOT NULL,
	[mppCspValue] [int] NOT NULL,
	[mppIdDsc] [int] NOT NULL,
	[mppIdUms] [int] NOT NULL,
	[mppIdMdl] [int] NULL,
	[mppSitoWeb] [nvarchar](300) NULL
) ON [PRIMARY]
GO
