USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_RicPrevPubblic_Prestiti]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_RicPrevPubblic_Prestiti](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[Peg] [varchar](40) NULL,
	[Quota] [float] NULL,
	[BurcGuri] [varchar](20) NULL
) ON [PRIMARY]
GO
