USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_SCRITTURA_PRIVATA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD_DASHBOARD_VIEW_SCRITTURA_PRIVATA] as
--Versione=2&data=2014-10-24&Attvita=64883&Nominativo=sabato

	select
		sp.Id, 
		sp.IdPfu, 
		sp.IdDoc, 
		sp.TipoDoc, 
		sp.StatoDoc, 
		sp.Data, 
		sp.Protocollo, 
		sp.PrevDoc, 
		sp.Deleted, 
		sp.Titolo, 
		sp.Body, 
		sp.Azienda, 
		sp.StrutturaAziendale, 
		sp.DataInvio, 
		--sp.DataScadenza, 
		sp.ProtocolloRiferimento, 
		sp.ProtocolloGenerale,
		sp.Fascicolo, 
		sp.Note, 
		sp.DataProtocolloGenerale, 
		sp.LinkedDoc, 
		sp.SIGN_HASH, 
		sp.SIGN_ATTACH, 
		sp.SIGN_LOCK, 
		sp.JumpCheck, 
		sp.StatoFunzionale, 
		sp.Destinatario_User, 
		sp.Destinatario_Azi, 
		sp.RichiestaFirma, 
		sp.NumeroDocumento, 
		sp.DataDocumento, 
		sp.Versione, 
		sp.VersioneLinkedDoc, 
		sp.GUID, 
		sp.idPfuInCharge, 
		sp.CanaleNotifica, 
		sp.URL_CLIENT, 
		sp.Caption, 
		sp.FascicoloGenerale,
		sp.tipodoc as OPEN_DOC_NAME,
		sp.destinatario_azi as muidazidest ,
		TipoProceduraCaratteristica,
		CV.Value as NewTotal,
		Cv2.Value as BodyContratto,
		convert( datetime, convert(varchar(10),Cv3.Value, 126 ))  as DataScadenza
--		rup.Value as UserRUP

	from ctl_doc sp
		left outer join CTL_DOC com on com.id = sp.linkedDoc -- PDA_COMUNICAZIONE_GENERICA
		left outer join CTL_DOC pda on pda.id = com.linkedDoc -- PDA_MICROLOTTI
		left outer join CTL_DOC B on B.id = PDA.linkedDoc -- BANDO_GARA
		left outer join document_bando  on B.id = idHeader
		left outer join CTL_DOC_Value CV with(nolock) on CV.IdHeader=sp.id and cv.DSE_ID='CONTRATTO' and cv.Row=0 and cv.DZT_Name='NewTotal'
		left outer join CTL_DOC_Value CV2 with(nolock) on CV2.IdHeader=sp.id and cv2.DSE_ID='CONTRATTO' and cv2.Row=0 and cv2.DZT_Name='BodyContratto'
		left outer join CTL_DOC_Value CV3 with(nolock) on CV3.IdHeader=sp.id and cv3.DSE_ID='CONTRATTO' and cv3.Row=0 and cv3.DZT_Name='DataScadenza'
--	    left outer join ctl_doc_value rup with (nolock) on B.id = rup.idHeader and  rup.dzt_name = 'UserRup' and rup.dse_id = 'InfoTec_comune'
	where sp.tipodoc='SCRITTURA_PRIVATA' and sp.deleted = 0	 

union all 

	select
		sp.Id, 
		rup.value as IdPfu, 
		sp.IdDoc, 
		sp.TipoDoc, 
		sp.StatoDoc, 
		sp.Data, 
		sp.Protocollo, 
		sp.PrevDoc, 
		sp.Deleted, 
		sp.Titolo, 
		sp.Body, 
		sp.Azienda, 
		sp.StrutturaAziendale, 
		sp.DataInvio, 
		--sp.DataScadenza, 
		sp.ProtocolloRiferimento, 
		sp.ProtocolloGenerale,
		sp.Fascicolo, 
		sp.Note, 
		sp.DataProtocolloGenerale, 
		sp.LinkedDoc, 
		sp.SIGN_HASH, 
		sp.SIGN_ATTACH, 
		sp.SIGN_LOCK, 
		sp.JumpCheck, 
		sp.StatoFunzionale, 
		sp.Destinatario_User, 
		sp.Destinatario_Azi, 
		sp.RichiestaFirma, 
		sp.NumeroDocumento, 
		sp.DataDocumento, 
		sp.Versione, 
		sp.VersioneLinkedDoc, 
		sp.GUID, 
		sp.idPfuInCharge, 
		sp.CanaleNotifica, 
		sp.URL_CLIENT, 
		sp.Caption, 
		sp.FascicoloGenerale,
		sp.tipodoc as OPEN_DOC_NAME,
		sp.destinatario_azi as muidazidest ,
		TipoProceduraCaratteristica,
		CV.Value as NewTotal,
		Cv2.Value as BodyContratto,
		convert( datetime, convert(varchar(10),Cv3.Value, 126 ))  as DataScadenza
--		rup.Value as UserRUP

	from ctl_doc sp
		left outer join CTL_DOC com on com.id = sp.linkedDoc -- PDA_COMUNICAZIONE_GENERICA
		left outer join CTL_DOC pda on pda.id = com.linkedDoc -- PDA_MICROLOTTI
		left outer join CTL_DOC B on B.id = PDA.linkedDoc -- BANDO_GARA
		left outer join document_bando  on B.id = idHeader
		left outer join CTL_DOC_Value CV with(nolock) on CV.IdHeader=sp.id and cv.DSE_ID='CONTRATTO' and cv.Row=0 and cv.DZT_Name='NewTotal'
		left outer join CTL_DOC_Value CV2 with(nolock) on CV2.IdHeader=sp.id and cv2.DSE_ID='CONTRATTO' and cv2.Row=0 and cv2.DZT_Name='BodyContratto'
		left outer join CTL_DOC_Value CV3 with(nolock) on CV3.IdHeader=sp.id and cv3.DSE_ID='CONTRATTO' and cv3.Row=0 and cv3.DZT_Name='DataScadenza'
	    left outer join ctl_doc_value rup with (nolock) on B.id = rup.idHeader and  rup.dzt_name = 'UserRup' and rup.dse_id = 'InfoTec_comune'
	where sp.tipodoc='SCRITTURA_PRIVATA' and sp.deleted = 0	 
		and rup.value  <> sp.idPfu


	


	

GO
