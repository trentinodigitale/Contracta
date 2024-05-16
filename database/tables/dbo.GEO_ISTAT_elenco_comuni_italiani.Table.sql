USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[GEO_ISTAT_elenco_comuni_italiani]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GEO_ISTAT_elenco_comuni_italiani](
	[CodiceRegione] [nvarchar](4000) NULL,
	[CodiceCittaMetropolitana] [nvarchar](4000) NULL,
	[CodiceProvincia] [nvarchar](4000) NULL,
	[CodiceComune] [nvarchar](4000) NULL,
	[CodiceIstatDelComune_formato_alfanumerico] [nvarchar](4000) NULL,
	[SoloDenominazione_in_italiano] [nvarchar](4000) NULL,
	[SoloDenominazione_in_tedesco] [nvarchar](4000) NULL,
	[CodiceRipartizioneGeografica] [nvarchar](4000) NULL,
	[RipartizioneGeografica] [nvarchar](4000) NULL,
	[DenominazioneRegione] [nvarchar](4000) NULL,
	[DenominazioneCittaMetropolitana] [nvarchar](4000) NULL,
	[DenominazioneProvincia] [nvarchar](4000) NULL,
	[ComuneCapoluogoDiProvincia] [nvarchar](4000) NULL,
	[SiglaAuto] [nvarchar](4000) NULL,
	[CodiceIstatDelComune_formato_numerico] [nvarchar](4000) NULL,
	[CodiceIstatDelComune_a_110_province_formato_numerico] [nvarchar](4000) NULL,
	[CodiceIstatDelComune_a_107_province_formato_numerico] [nvarchar](4000) NULL,
	[CodiceIstatDelComune_a_103_province_formato_numerico] [nvarchar](4000) NULL,
	[CodiceCatastale] [nvarchar](4000) NULL,
	[Popolazionelegale_2011] [nvarchar](4000) NULL,
	[CodiceNUTS1_2010] [nvarchar](4000) NULL,
	[CodiceNUTS2_2010] [nvarchar](4000) NULL,
	[CodiceNUTS3_2010] [nvarchar](4000) NULL,
	[CodiceNUTS1_2006] [nvarchar](4000) NULL,
	[CodiceNUTS2_2006] [nvarchar](4000) NULL,
	[CodiceNUTS3_2006] [nvarchar](4000) NULL,
	[deleted] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GEO_ISTAT_elenco_comuni_italiani] ADD  DEFAULT ((0)) FOR [deleted]
GO
