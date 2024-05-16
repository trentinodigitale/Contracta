USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SITAR_XML_IMPRESE_AGGIUDICATARIE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[SITAR_XML_IMPRESE_AGGIUDICATARIE] as 

	select 
			[idRow], [idHeader], [idAzi], [CFIMP], [NOMIMP], [W3AGIDGRP], [W3ID_TIPOA], [W3RUOLO], [W3FLAG_AVV],
			[G_NAZIMP], [INDIMP], [NCIIMP], [LOCIMP], [TELIMP], [FAXIMP], [EMAI2IP], [NCCIAA], [AGGAUS], [CAPIMP]
			, I.CFIMP_AUSILIARIA 

			, ltrim( str( i.W3AGIMP_AGGI  , 25 , 2 ) ) as W3AGIMP_AGGI
			, case when isnull(i.W3AGIMP_AGGI,0) > 0 and isnull(i.W3AGPERC_RIB,0) = 0 then ltrim( str( i.W3AGPERC_OFF  , 25 , 2 ) ) else NULL end as W3AGPERC_OFF --Non valorizzare insieme a W3AGPERC_RIB.)
			, case when isnull(i.W3AGIMP_AGGI,0) = 0 or isnull(i.W3AGPERC_RIB,0) = 0 or isnull(i.W3AGPERC_RIB,0) <> 0 then NULL else ltrim( str( W3AGPERC_RIB  , 25 , 2 ) )  end as W3AGPERC_RIB --Non valorizzare insieme a W3AGPERC_OFF

			,c.LinkedDoc -- l'idrow della Document_OCP_LOTTI_AGGIUDICATI

		from Document_OCP_IMPRESE_AGGIUDICATARIE I with(nolock)
					INNER JOIN CTL_DOC c with(nolock) on c.id = i.idHeader and c.tipodoc = 'OCP_IMPRESE_AGGIUDICATARIE'
GO
