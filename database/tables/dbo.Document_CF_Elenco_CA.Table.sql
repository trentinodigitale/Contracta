USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_CF_Elenco_CA]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_CF_Elenco_CA](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[deleted] [int] NULL,
	[codiceFiscale] [varchar](50) NULL,
	[aziRagioneSociale] [nvarchar](1000) NULL
) ON [PRIMARY]
GO
