USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Mod69_SoggettiGiuridici]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Mod69_SoggettiGiuridici](
	[idrow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[idazi] [int] NOT NULL,
	[aziRagioneSociale] [nvarchar](1000) NULL,
	[aziPartitaIVA] [varchar](50) NULL,
	[aziIndirizzoLeg] [varchar](150) NULL,
	[aziLocalitaLeg] [varchar](150) NULL,
	[aziProvinciaLeg] [varchar](50) NULL,
	[NumeroCivico] [varchar](20) NULL
) ON [PRIMARY]
GO
