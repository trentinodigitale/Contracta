USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_RDA_Prestiti]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_RDA_Prestiti](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[PegPrestante] [varchar](40) NULL,
	[QuotaPrestante] [float] NULL,
	[RDP_VDS] [nvarchar](20) NULL,
	[RDP_TiketBudget] [int] NULL
) ON [PRIMARY]
GO
