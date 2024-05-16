USE [AFLink_TND]
GO
/****** Object:  View [dbo].[FLES_VIEW_CONTRATTO_TESTATA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE         VIEW [dbo].[FLES_VIEW_CONTRATTO_TESTATA] AS
	select
		sp.Id, 
		sp.IdPfu, 
		(select pfuNome from DASHBOARD_VIEW_UTENTI dshViewUte where dshViewUte.IdPfu = sp.idPfuInCharge) as inCarico,  --OK > (Utente in carico  Frontend Dettaglio)
		(select pfuNome from DASHBOARD_VIEW_UTENTI dshViewUte where dshViewUte.IdPfu = sp.IdPfu) as compilatore,  --OK > (Compilatore  Frontend Dettaglio)
		sp.Protocollo, ---OK > (Registro di Sistema Contratto Frontend)
		sp.Body ,      -- (Oggetto Bando -  St.Appaltante Fronend Dettaglio)
		sp.Azienda,
		sp.DataInvio, -- ok > (Data Invio Contratto Frontend)
		sp.ProtocolloRiferimento,   -- (Registro di Sistema Bando - St.Appaltante Fronend Dettaglio)
		sp.Fascicolo,                 -- (Fascicolo di Sistema - St.Appaltante Fronend Dettaglio)
		sp.StatoFunzionale,  --OK > (Stato  Frontend)
		(select aziRagioneSociale from AZIENDE_SCHEDA_ANAGRAFICA azSchAna where azSchAna.IdAzi = sp.Destinatario_Azi) as aggiudicatario,  --OK > (Aggiudicatario  Frontend)
		sp.idPfuInCharge,
		sp.FascicoloGenerale,      -- (Fascicolo  - St.Appaltante Fronend Dettaglio Rdo) 
		sp.destinatario_azi as muidazidest,
		B.id as idBando,
		doc_bando.CIG,    -- CIG,
		B.DataInvio as Data_Bando,  -- (Data Bando  Staz Appaltante Dettaglio)
		rup.Value as UserRUP,
		firm.value as IdPfu_Firmatario,
		(select docPcpApp.pcp_CodiceAppalto  from  Document_PCP_Appalto docPcpApp where  docPcpApp.idHeader = b.Id) as idAppalto,
		(select top (1) sc.idContratto from Document_PCP_Appalto_schede sc, ctl_doc lik where sc.tipoScheda like'SC1' and sc.statoScheda = 'SC_CONF' and sc.IdDoc_Scheda = lik.id and lik.LinkedDoc =sp.id  and lik.TipoDoc='CONTRATTO_GARA_FORN' and lik.Deleted=0 and lik.StatoFunzionale='Confermato'
		    order by sc.dateInsert desc) as idContratto,
		sp.LinkedDoc as LinkedDocSp,
		pda.LinkedDoc,  -- (Per inserimento PCP)
		sp.Deleted,
		(select pfuNome from DASHBOARD_VIEW_UTENTI dshViewUte where dshViewUte.IdPfu = Convert(INT,CV.Value)) as DirettoreEsecuzioneContratto,
		CV.Value as IdDec,
		Cv1.Value as BodyContratto
	from ctl_doc sp with(nolock)
		left outer join CTL_DOC com with(nolock) on com.id = sp.linkedDoc	-- PDA_COMUNICAZIONE_GENERICA
		left outer join CTL_DOC pda with(nolock) on pda.id = com.linkedDoc	-- PDA_MICROLOTTI
		left outer join CTL_DOC B with(nolock) on B.id = PDA.linkedDoc		-- BANDO_GARA
		left outer join CTL_DOC_Value CV with(nolock) on CV.IdHeader=sp.id and cv.DSE_ID='CONTRATTO' and cv.Row=0 and cv.DZT_Name='DirettoreEsecuzioneContratto'
		left outer join CTL_DOC_Value CV1 with(nolock) on CV1.IdHeader=sp.id and cv1.DSE_ID='CONTRATTO' and cv1.Row=0 and cv1.DZT_Name='BodyContratto'
		left outer join document_bando doc_bando with(nolock)  on B.id = doc_bando.idHeader -- Sono Id Bando tutti e due
	    left outer join ctl_doc_value rup with (nolock) on B.id = rup.idHeader and rup.dzt_name = 'UserRup' and rup.dse_id = 'InfoTec_comune'
		left outer join ctl_doc_value firm with (nolock) on sp.id = firm.idHeader and firm.dzt_name = 'IdPfu_Firmatario' and firm.dse_id = 'CONTRATTO'
	where  sp.deleted = 0 

GO
