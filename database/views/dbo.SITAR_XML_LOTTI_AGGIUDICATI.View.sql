USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SITAR_XML_LOTTI_AGGIUDICATI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [dbo].[SITAR_XML_LOTTI_AGGIUDICATI] as 

	select l.[idRow], l.[idHeader],
			[NumeroLotto], [W3OGGETTO2], [W3CIG], [W3MOD_IND], [W3IMPR_AMM], [W3IMPR_OFF], 

			convert(varchar, [W3DVERB], 126) as [W3DVERB],
			convert(varchar, [W3DSCAPO], 126) as [W3DSCAPO],

			ltrim( str( [W3IMP_AGGI]  , 25 , 2 ) ) as [W3IMP_AGGI], 

			--ltrim( str( W3PERC_RIB  , 25 , 2 ) ) as [W3PERC_RIB], 
			--kpf 429209 essendo opzionale quando è zero non passeremo il tag
			case when  W3PERC_RIB   = 0 then NULL else ltrim( str( W3PERC_RIB  , 25 , 2 ) )  end as [W3PERC_RIB],
			[W3FLAG_RIC], 
			
			ltrim( str( [W3OFFE_MAX]  , 25 , 2 ) ) as [W3OFFE_MAX], 
			ltrim( str( [W3OFFE_MIN]  , 25 , 2 ) ) as [W3OFFE_MIN], 
			ltrim( str( [W3I_SUBTOT]  , 25 , 2 ) ) as [W3I_SUBTOT], 
			
			convert(varchar, [W9APDATA_STI], 126) as [W9APDATA_STI],
			
			ltrim( str( W3PERC_OFF  , 25 , 2 ) ) as W3PERC_OFF,

			g.W9APOUSCOMP,
			g.W3PROCEDUR,
			g.W3PREINFOR,
			g.W3TERMINE,
			g.W3RELAZUNIC,

			ltrim( str( l.W3I_FINANZ , 25 , 2 ) ) as W3I_FINANZ,
			l.W3ID_FINAN
			
		from Document_OCP_LOTTI_AGGIUDICATI L with(nolock)
				inner join document_ocp_gara g with(nolock) on g.idHeader = l.idHeader
GO
