USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[GEO_ISTAT_ripartizioni_regioni_province]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GEO_ISTAT_ripartizioni_regioni_province](
	[CodiceRipartizione] [nvarchar](4000) NULL,
	[CodiceNUTS1_2006] [nvarchar](4000) NULL,
	[CodiceNUTS1_2010] [nvarchar](4000) NULL,
	[RipartizioneGeografica_Maiuscolo] [nvarchar](4000) NULL,
	[RipartizioneGeografica] [nvarchar](4000) NULL,
	[CodiceRegione] [nvarchar](4000) NULL,
	[CodiceNUTS2_2006] [nvarchar](4000) NULL,
	[CodiceNUTS2_2010] [nvarchar](4000) NULL,
	[DenominazioneRegione_Maiuscolo] [nvarchar](4000) NULL,
	[DenominazioneRegione] [nvarchar](4000) NULL,
	[CodiceProvincia] [nvarchar](4000) NULL,
	[CodiceNUTS3_2006] [nvarchar](4000) NULL,
	[CodiceNUTS3_2010] [nvarchar](4000) NULL,
	[DenominazioneProvincia] [nvarchar](4000) NULL,
	[SiglaAutomobilistica] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
