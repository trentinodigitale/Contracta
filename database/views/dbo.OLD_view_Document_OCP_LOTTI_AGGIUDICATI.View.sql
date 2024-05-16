USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_view_Document_OCP_LOTTI_AGGIUDICATI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_view_Document_OCP_LOTTI_AGGIUDICATI] as 

	select 
			[idHeader], [NumeroLotto], [W3OGGETTO2], [W3CIG], [W3MOD_IND], [W3IMPR_AMM], [W3IMPR_OFF], [W3DVERB], [W3DSCAPO], [W3IMP_AGGI], [W3PERC_RIB], [W3FLAG_RIC], [W3OFFE_MAX], [W3OFFE_MIN], [W3I_SUBTOT], [W9APDATA_STI]

			,W3PERC_OFF
			,c.TipoDoc as OPEN_DOC_NAME
			, c.id as idRow
		from Document_OCP_LOTTI_AGGIUDICATI I with(nolock)
				INNER JOIN CTL_DOC c with(nolock) on c.LinkedDoc = i.idrow and c.tipodoc = 'OCP_IMPRESE_AGGIUDICATARIE' and c.Deleted = 0
GO
