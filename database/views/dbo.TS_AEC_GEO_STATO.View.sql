USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TS_AEC_GEO_STATO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TS_AEC_GEO_STATO] AS

	select  iso_3166_1_3_lettercode as lettercod_stato,
			iso_3166_1_number as internal_numbercod_stato,
			isnull( b.ValOut, '799') as extCodStato -- in assenza della trascodifica passiamo il codice 86 ( italia )
			--,b.ValIn 
		from GEO_Elenco_Stati_ISO_3166_1 a WITH(NOLOCK)
				left join ctl_transcodifica b with(nolock) on b.Sistema = 'TS_AEC' and b.dztNome = 'stato' and b.ValIn = a.iso_3166_1_2_lettercode

GO
