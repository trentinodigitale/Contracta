USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV_INDIRETTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV_INDIRETTI]  
--Versione=5&data=2014-09-25&Attivita=63183&Nominativo=Enrico
--Versione=6&data=2015-02-27&Attivita=70503&Nominativo=Enrico

--agg indiretti sui nuovi bandi
as
--select IdMsg,PO.idpfu, msgIType, msgISubType, IDDOCR, Precisazioni, Name, 
--		0 as bRead, ProtocolloBando, ProtocolloOfferta, ReceivedDataMsg, Oggetto, 
--		Tipologia, expirydate, ImportoBaseAsta, tipoprocedura, StatoGD, PO.Fascicolo, 
--		CriterioAggiudicazione, CriterioFormulazioneOfferta, OpenDettaglio, Scaduto, IdDoc, 
--		TipoBando, CIG, StatoCollegati, OPEN_DOC_NAME, OpenOfferte, EnteAppaltante
	
--	from	
--		DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV_INDIRETTI_SUB D 
		
--		inner join
--			(	
--				--prendo min  degli invitati e faccio group by P.idpfu,fascicolo per evitare di avere bandi duplicati negli indiretti
--				--quando un fornitore partecipa indirettamente + volte con diversi altri fornitori
--				select 
--					P.idpfu,fascicolo,min(D.IdPfu) as IdPfuInvitato, mfFieldValue as IdDocBando_Invito
--					--distinct P.idpfu,fascicolo,D.IdPfu as IdPfuInvitato
--				from 
--					ctl_doc D , document_offerta_partecipanti DO ,  Profiliutente P , MessageFields MF 
--				where 
--					D.tipodoc='OFFERTA_PARTECIPANTI' and DO.idheader=D.id 
--					and DO.TipoRiferimento in ('RTI','ESECUTRICI') and isnull(DO.Ruolo_impresa,'') <> 'Mandataria'
--					and P.pfuidazi=idazi
--					and mfIdMsg=D.linkedDoc
--					and D.jumpcheck='DocumentoGenerico'
--					and mfFieldName='IdDoc_Bando'
--					and D.statofunzionale='Pubblicato'
--					--and fascicolo='PROVV01210'
--				group by P.idpfu,fascicolo,mfFieldValue

--			)PO on D.fascicolo=PO.fascicolo and D.idpfu = PO.IdPfuInvitato and PO.IdDocBando_Invito=IdDoc
--		where
--			D.OPEN_DOC_NAME=''
--union all
select IdMsg,PO.idpfu, msgIType, msgISubType, IDDOCR, Precisazioni, Name, 0 as bRead, ProtocolloBando, ProtocolloOfferta, ReceivedDataMsg, Oggetto, Tipologia, expirydate, ImportoBaseAsta, tipoprocedura, StatoGD, PO.Fascicolo, CriterioAggiudicazione, CriterioFormulazioneOfferta, OpenDettaglio, Scaduto, IdDoc, TipoBando, CIG, StatoCollegati, OPEN_DOC_NAME, OpenOfferte , EnteAppaltante , [TipoProceduraCaratteristica]
	from	
		DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV_INDIRETTI_SUB D  with(nolock) 
		
		inner join
			(	
				--prendo min  degli invitati e faccio group by P.idpfu,fascicolo per evitare di avere bandi duplicati negli indiretti
				--quando un fornitore partecipa indirettamente + volte con diversi altri fornitori
				select 
					P.idpfu,D.fascicolo,min(D.IdPfu) as IdPfuInvitato, MF.linkeddoc as IdDocBando_Invito
					--distinct P.idpfu,fascicolo,D.IdPfu as IdPfuInvitato
				from 
					ctl_doc D  with(nolock) , document_offerta_partecipanti DO  with(nolock) ,  Profiliutente P  with(nolock) , ctl_doc MF  with(nolock) 
				where 
					D.tipodoc='OFFERTA_PARTECIPANTI' and DO.idheader=D.id 
					and DO.TipoRiferimento in ('RTI','ESECUTRICI') and isnull(DO.Ruolo_impresa,'') <> 'Mandataria'
					and P.pfuidazi=idazi
					and MF.ID=D.linkedDoc
					and D.jumpcheck <> 'DocumentoGenerico'
					and D.statofunzionale='Pubblicato'
					--and D.fascicolo='FE000441'
				group by P.idpfu,D.fascicolo,MF.linkeddoc

			)PO on D.fascicolo=PO.fascicolo and D.idpfu = PO.IdPfuInvitato and PO.IdDocBando_Invito=IdMsg
				
				inner join ProfiliUtenteAttrib pa  with(nolock) on pa.idpfu = po.idpfu and dztnome = 'Profilo' and attvalue = 'ACCESSO_DOC_OE'

		where
			D.OPEN_DOC_NAME<>''






GO
