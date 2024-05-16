USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_FLES_VIEW_CONTRATTO_RDO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE     view [dbo].[OLD2_FLES_VIEW_CONTRATTO_RDO] as
	select
		sp.Id, 
		sp.IdPfu,
		sp.Protocollo, ---OK > (Registro di Sistema Contratto Frontend) 
		sp.DataInvio, 
		sp.StatoFunzionale,   --OK > (Stato  Frontend)
		(select aziRagioneSociale from AZIENDE_SCHEDA_ANAGRAFICA azSchAna where azSchAna.IdAzi = sp.Destinatario_Azi) as aggiudicatario,  --OK > (Aggiudicatario  Frontend)
		sp.idPfuInCharge, 
		CV.Value as NewTotal,                  -- OK > (Valore Contratto Frontend) 
		Cv2.Value as BodyContratto,           
		B.id as idBando,
		rup.Value as UserRUP
	from ctl_doc sp with(nolock)
		left outer join CTL_DOC com with(nolock) on com.id = sp.linkedDoc -- PDA_COMUNICAZIONE_GENERICA
		left outer join CTL_DOC pda with(nolock) on pda.id = com.linkedDoc -- PDA_MICROLOTTI
		left outer join CTL_DOC B with(nolock)  on B.id = PDA.linkedDoc -- BANDO_GARA
		left outer join CTL_DOC_Value CV with(nolock) on CV.IdHeader=sp.id and cv.DSE_ID='CONTRATTO' and cv.Row=0 and cv.DZT_Name='NewTotal'
		left outer join CTL_DOC_Value CV2 with(nolock) on CV2.IdHeader=sp.id and cv2.DSE_ID='CONTRATTO' and cv2.Row=0 and cv2.DZT_Name='BodyContratto'
		left outer join ctl_doc_value rup with (nolock) on B.id = rup.idHeader and  rup.dzt_name = 'UserRup' and rup.dse_id = 'InfoTec_comune'
	where sp.tipodoc='SCRITTURA_PRIVATA' and sp.deleted = 0


GO
