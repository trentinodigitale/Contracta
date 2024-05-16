USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_FLES_VIEW_CONTRATTO_SC1]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE     VIEW [dbo].[OLD_FLES_VIEW_CONTRATTO_SC1] AS
		select
		fls_viewCrtTst.*,
		CV.Value as DataStipula,           --- Per Stipulato, Totale per RDO
		CV2.Value as  Importo_Cauzione,                         --- Per Stipulato, Totale per RDO
	    CV3.Value AS DataScadenza,		    --- Per Stipulato, Totale per RDO
		CV4.Value AS Oneri,                                      --- Per Stipulato, Totale per RDO
		cv5.value AS ValoreContratto 						      --- Per Stipulato, Totale per RDO
	from FLES_VIEW_CONTRATTO_TESTATA fls_viewCrtTst with(nolock)
		left outer join CTL_DOC com with(nolock) on com.id = fls_viewCrtTst.LinkedDocSp	-- PDA_COMUNICAZIONE_GENERICA
		left outer join CTL_DOC pda with(nolock) on pda.id = com.linkedDoc	-- PDA_MICROLOTTI
		left outer join CTL_DOC B with(nolock) on B.id = PDA.linkedDoc		-- BANDO_GARA
		left outer join document_bando doc_bando with(nolock)  on B.id = doc_bando.idHeader -- Sono Id Bando tutti e due
		left outer join CTL_DOC_Value CV with(nolock) on CV.IdHeader=fls_viewCrtTst.id and cv.DSE_ID='CONTRATTO' and cv.Row=0 and cv.DZT_Name='DataStipula'
		left outer join CTL_DOC_Value CV2 with(nolock) on CV2.IdHeader=fls_viewCrtTst.id and cv2.DSE_ID='CONTRATTO' and cv2.Row=0 and cv2.DZT_Name='Importo_Cauzione'
		left outer join CTL_DOC_Value CV3 with(nolock) on CV3.IdHeader=fls_viewCrtTst.id and cv3.DSE_ID='CONTRATTO' and cv3.Row=0 and cv3.DZT_Name='DataScadenza'
		left outer join CTL_DOC_Value CV4 with(nolock) on CV4.IdHeader=fls_viewCrtTst.id and cv4.DSE_ID='CONTRATTO' and cv4.Row=0 and cv4.DZT_Name='Oneri'
		left outer join CTL_DOC_Value CV5 with(nolock) on CV5.IdHeader=fls_viewCrtTst.id and cv5.DSE_ID='CONTRATTO' and cv5.Row=0 and cv5.DZT_Name='NewTotal'
	    left outer join ctl_doc_value rup with (nolock) on B.id = rup.idHeader and rup.dzt_name = 'UserRup' and rup.dse_id = 'InfoTec_comune'
		left outer join ctl_doc_value firm with (nolock) on fls_viewCrtTst.id = firm.idHeader and firm.dzt_name = 'IdPfu_Firmatario' and firm.dse_id = 'CONTRATTO'
	where fls_viewCrtTst.deleted = 0

GO
