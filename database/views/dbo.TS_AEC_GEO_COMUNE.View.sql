USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TS_AEC_GEO_COMUNE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TS_AEC_GEO_COMUNE] AS
	select  CodiceCatastale,
			SiglaAuto, 
			CodiceIstatDelComune_formato_alfanumerico as codIstatAlfa
		from GEO_ISTAT_elenco_comuni_italiani with(nolock)
GO
