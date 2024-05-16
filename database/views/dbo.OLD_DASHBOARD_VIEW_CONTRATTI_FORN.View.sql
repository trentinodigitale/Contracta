USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_CONTRATTI_FORN]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_CONTRATTI_FORN] AS
	--
	select
		--sp.*,
		sp.id,
		sp.protocollo,
		sp.DataInvio,
		sp.StatoFunzionale,
		--sp.tipodoc + '_FORN' as OPEN_DOC_NAME,
		sp.tipodoc as OPEN_DOC_NAME,
		sp.destinatario_azi as muidazidest,
		sp.Azienda as muidaziMitt,
		p.IdPfu as owner,
		CV.Value as NewTotal,
		Cv2.Value as BodyContratto,
		sp.tipodoc as tipodoc
		
	from ctl_doc sp with(nolock)
		inner join ProfiliUtente p with(nolock) on p.pfuIdAzi=sp.destinatario_azi and pfuDeleted=0
		--left outer join CTL_DOC com on com.id = sp.linkedDoc	-- PDA_COMUNICAZIONE_GENERICA
		--left outer join CTL_DOC pda on pda.id = com.linkedDoc	-- PDA_MICROLOTTI
		--left outer join CTL_DOC B on B.id = PDA.linkedDoc		-- BANDO_GARA
		--left outer join document_bando  on B.id = idHeader
		left outer join CTL_DOC_Value CV with(nolock) on CV.IdHeader=sp.id and cv.DSE_ID='CONTRATTO' and cv.Row=0 and cv.DZT_Name='NewTotal'
		left outer join CTL_DOC_Value CV2 with(nolock) on CV2.IdHeader=sp.id and cv2.DSE_ID='CONTRATTO' and cv2.Row=0 and cv2.DZT_Name='BodyContratto'
	where sp.tipodoc='CONTRATTO_GARA_FORN' and sp.deleted = 0 and StatoFunzionale  not in ('InLavorazione','Annullato')
	
	UNION ALL
	--AGGIUNGO GLI ODC
	select 
		sp.RDA_Id as id,
		sp.Protocollo,
		sp.Data as DataInvio,
		sp.StatoFunzionale,
		sp.tipodoc as OPEN_DOC_NAME,
		sp.AZI_Dest as muidazidest,
		sp.Azienda as muidaziMitt,
		sp.idPfuInCharge as owner,
		sp.RDA_Total as NewTotal,
		sp.note as BodyContratto,
		sp.tipodoc as tipodoc
		
	from [DASHBOARD_VIEW_ODC_FORNITORE] sp

	UNION ALL
	--AGGIUNGO I CONTRATTI SU RDO
	select 
		sp.IdMsg as id,
		c.Protocollo,
		C.DataInvio,
		c.StatoFunzionale,
		'SCRITTURA_PRIVATA_FORN' as OPEN_DOC_NAME,
		c.Destinatario_Azi as muidazidest,
		C.Azienda as muidaziMitt,
		sp.idpfu as owner,
		CV.Value as NewTotal,
		sp.Oggetto as BodyContratto,
		c.tipodoc as tipodoc
		
		
		from MSG_LINKED_ISCRIZIONE_ALBO sp
			inner join CTL_DOC C with(nolock) on C.Id=sp.IdMsg and C.TipoDoc='SCRITTURA_PRIVATA'
			inner join ctl_doc_value CV  with(nolock) on CV.IdHeader=C.Id and CV.DSE_ID='CONTRATTO' and CV.DZT_Name='NewTotal' 
			where Folder='SCRITTURA_PRIVATA'
GO
