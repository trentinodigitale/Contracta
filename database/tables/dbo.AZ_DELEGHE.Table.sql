USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[AZ_DELEGHE]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AZ_DELEGHE](
	[IdAz] [int] NOT NULL,
	[IdDelega] [int] NOT NULL,
	[Path] [varchar](100) NOT NULL,
	[Descrizione] [nvarchar](100) NOT NULL,
	[IdCategoria] [int] NULL,
	[PathCategoria] [varchar](20) NULL,
	[DataUModifica] [datetime] NULL,
	[Deleted] [bit] NOT NULL
) ON [PRIMARY]
GO
