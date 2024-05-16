USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_CHIARIMENTI_PORTALE_BANDO_NEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD2_CHIARIMENTI_PORTALE_BANDO_NEW] AS
	select
		CTL_DOC.id as iddoc,
		CTL_DOC.id as id_origin,
		cast(body as nvarchar(4000)) as oggetto,
		Protocollo as ProtocolloBando,
		datascadenza as expirydate,
		a.id,a.domanda,a.aziragionesociale,a.azitelefono1,a.azifax,
		a.azie_mail,a.protocol,a.allegato,
		left(
		(convert(varchar(20),cast(a.datacreazione as datetime),105) + ' ' +
		convert(varchar(20),cast(a.datacreazione as datetime),114)),16) as datacreazione,
		a.datacreazione as datacreazione1,
		a.ChiarimentoEvaso,
		a.ChiarimentoPubblico,a.Notificato,a.UtenteDomanda,a.UtenteRisposta,a.risposta,
		a.protocolrispostaquesito,a.datarisposta,a.fascicolo
		,a.domandaoriginale
		,a.ProtocolloGenerale, a.DataProtocolloGenerale
		---Controllo fatto per attivare il pubblica del chiarimento
		--RIVISTO IN QUANTO HANNO RICHIESTO DI CONSENTIRE DI PUBBLICARE SOLO AL RUP
			, 
		case 
			--per i quesiti dei BANDI_ME devo ESSERE RUP
			when a.document = 'BANDO' and CV2.Idpfu=a.idPfuInCharge /*and  ISNULL(cv2.idPfu,'') <> '' */ then 1 
			--per i quesiti dei BANDI_SDA  devo ESSERE RUP
			when a.document = 'BANDO_SDA' and  CV2.Idpfu=a.idPfuInCharge /*ISNULL(cv2.idPfu,'') <> '' */ then 1 
			--per i quesiti dei BANDI_SEMPLIFICATI  devo ESSERE RUP
			when a.document = 'BANDO_SEMPLIFICATO' and ISNULL(cv.Value,'') <> ''  then 1
			--per i quesiti dei BANDI_GARA devo ESSERE RUP
			when a.document = 'BANDO_GARA' and ISNULL(band.TipoProceduraCaratteristica,'') <> 'RDO'  and ISNULL(cv.Value,'') <> ''  then 1
			--per i quesiti dei BANDI_RDO devo ESSERE RUP
			when a.document = 'BANDO_GARA' and ISNULL(band.TipoProceduraCaratteristica,'') = 'RDO' and ISNULL(cv.Value,'') <> ''  then 1			
			--per i quesiti dei BANDI_ASTA devo ESSERE RUP
			when a.document = 'BANDO_ASTA' and  ISNULL(cv.Value,'') <> '' then 1
			--per i quesiti dei BANDO_CONSULTAZIONE devo ESSERE RUP
			when a.document = 'BANDO_CONSULTAZIONE' and ISNULL(cv.Value,'') <> '' then 1 
			
			else 0
		end as ABILITATO
		--, 
		--case 
		--	--per i quesiti dei BANDI_ME devo avere il profilo responsabile albo ed avere uno dei 3 ruoli (PO,RUP.RUP_PDG)
		--	when a.document = 'BANDO' and ( ISNULL(p4.idpfu,'') <> '' or ISNULL(p6.idpfu,'') <> '' or ISNULL(p7.idpfu,'') <> '' )  and ( ISNULL(p.idpfu,'') <> '' or ISNULL(p2.idpfu,'') <> '' or ISNULL(p3.idpfu,'') <> '' ) then 1 
		--	--per i quesiti dei BANDI_SDA devo avere il profilo GESTORE_SDA ed avere uno dei 3 ruoli (PO,RUP.RUP_PDG)
		--	when a.document = 'BANDO_SDA' and ISNULL(p5.idpfu,'') <> '' and ( ISNULL(p.idpfu,'') <> '' or ISNULL(p2.idpfu,'') <> '' or ISNULL(p3.idpfu,'') <> '' ) then 1 
		--	--per i quesiti dei BANDI_SEMPLIFICATI devo avere il ruolo RUP_PDG
		--	when a.document = 'BANDO_SEMPLIFICATO' and ( ISNULL(p2.idpfu,'') <> '' and ISNULL(cv.Value,'') <> '' ) then 1
		--	--per i quesiti dei BANDI_GARA devo avere il ruolo RUP_PDG
		--	when a.document = 'BANDO_GARA' and ISNULL(band.TipoProceduraCaratteristica,'') <> 'RDO' and ( ISNULL(p2.idpfu,'') <> '' and ISNULL(cv.Value,'') <> '' ) then 1
		--	--per i quesiti dei BANDI_RDO devo avere il ruolo PO oppure RUP
		--	when a.document = 'BANDO_GARA' and ISNULL(band.TipoProceduraCaratteristica,'') = 'RDO' and ( ( ISNULL(p.idpfu,'') <> '' or ISNULL(p3.idpfu,'') <> '' ) and ISNULL(cv.Value,'') <> '' ) then 1
			
		--	--per i quesiti dei BANDI_ASTA devo avere il ruolo RUP oppure RUP_PDG
		--	when a.document = 'BANDO_ASTA' and ( ISNULL(p2.idpfu,'') <> '' or ISNULL(p3.idpfu,'') <> '' ) then 1
		--	--per i quesiti dei BANDO_CONSULTAZIONE devo avere il profilo CONS_PREL_MERCATO ed avere uno dei 3 ruoli (PO,RUP.RUP_PDG)
		--	when a.document = 'BANDO_CONSULTAZIONE' and ISNULL(p8.idpfu,'') <> '' and ( ISNULL(p.idpfu,'') <> '' or ISNULL(p2.idpfu,'') <> '' or ISNULL(p3.idpfu,'') <> '' ) then 1 
			

		--	else 0
		--end as ABILITATO

		--, case when p.idpfu is null then 0 else 1 end as isPO
		--, case when ( ISNULL(p2.idpfu,'') <> '' or ISNULL(p3.idpfu,'') <> '' ) and ( a.Document='BANDO_SDA' or band.TipoProceduraCaratteristica='RDO' ) then 1 else 0 end as isRUP_PDG

		,isnull( cast( a.idPfuInCharge as varchar(10)) , '0' ) as idPfuInCharge
		,a.StatoFunzionale,
		
		--OBSOLETO SUL MODELLO IL CAMPO ChiarimentoEvaso è non EDITABLE
		--,case 
		--	--per i quesiti dei BANDI_ME devo avere uno dei profili (responsabile albo,GestoreAlboLavori,GESTORE_ALBO_FORN) ed avere uno dei 3 ruoli (PO,RUP.RUP_PDG)
		--	when a.document = 'BANDO' and ( ISNULL(p4.idpfu,'') <> '' or ISNULL(p6.idpfu,'') <> '' or ISNULL(p7.idpfu,'') <> '') and ( ISNULL(p.idpfu,'') <> '' or ISNULL(p2.idpfu,'') <> '' or ISNULL(p3.idpfu,'') <> '' ) then '' 
		--	--per i quesiti dei BANDI_SDA devo avere il profilo GESTORE_SDA ed avere uno dei 3 ruoli (PO,RUP.RUP_PDG)
		--	when a.document = 'BANDO_SDA' and ISNULL(p5.idpfu,'') <> '' and ( ISNULL(p.idpfu,'') <> '' or ISNULL(p2.idpfu,'') <> '' or ISNULL(p3.idpfu,'') <> '' ) then '' 
		--	--per i quesiti dei BANDI_SEMPLIFICATI devo avere il ruolo RUP_PDG
		--	when a.document = 'BANDO_SEMPLIFICATO' and ISNULL(p2.idpfu,'') <> '' then ''
		--	--per i quesiti dei BANDI_GARA devo avere il ruolo RUP_PDG
		--	when a.document = 'BANDO_GARA' and ISNULL(band.TipoProceduraCaratteristica,'') <> 'RDO' and ISNULL(p2.idpfu,'') <> '' then ''
		--	--per i quesiti dei BANDI_RDO devo avere il ruolo PO oppure RUP
		--	when a.document = 'BANDO_GARA' and ISNULL(band.TipoProceduraCaratteristica,'') = 'RDO' and ( ISNULL(p.idpfu,'') <> '' or ISNULL(p3.idpfu,'') <> '' ) then ''

		--	--per i quesiti dei BANDI_ASTA devo avere il ruolo RUP oppure RUP_PDG
		--	when a.document = 'BANDO_ASTA' and ( ISNULL(p2.idpfu,'') <> '' or ISNULL(p3.idpfu,'') <> '' ) then ''
		--	--per i quesiti dei BANDO_CONSULTAZIONE devo avere il profilo CONS_PREL_MERCATO ed avere uno dei 3 ruoli (PO,RUP.RUP_PDG)
		--	when a.document = 'BANDO_CONSULTAZIONE' and ISNULL(p8.idpfu,'') <> '' and ( ISNULL(p.idpfu,'') <> '' or ISNULL(p2.idpfu,'') <> '' or ISNULL(p3.idpfu,'') <> '' ) then '' 
			

		--	else ' ChiarimentoEvaso '
		--end 
		' ' as NonEditabili

		--, case when p.idpfu is null then ' ChiarimentoEvaso ' else '' end as NonEditabili

		, a.Document
		, isnull(band.TipoProceduraCaratteristica,'') as TipoGara
		, a.ProtocolloGeneraleIN
		, a.DataProtocolloGeneraleIN
		, Azienda
		, a.Pubblicazione_auto_Richiesta
		 , dbo.ListRiferimentiBando(CTL_DOC.id,'quesiti') as ListRiferimentiBando
		 ,	isnull( rup.Value , CV2.Idpfu ) as UserRUP
		from CTL_DOC
		left join document_chiarimenti a with (nolock) on a.id_origin=CTL_DOC.id and ISNULL(Document,'')<>''
		--left join ProfiliUtenteAttrib p with(nolock) on p.idpfu = a.idPfuInCharge and p.dztNome = 'UserRole' and p.attvalue = 'PO'
		--left join ProfiliUtenteAttrib p2 with(nolock) on p2.idpfu = a.idPfuInCharge and p2.dztNome = 'UserRole' and p2.attvalue = 'RUP_PDG'
		--left join ProfiliUtenteAttrib p3 with(nolock) on p3.idpfu = a.idPfuInCharge and p3.dztNome = 'UserRole' and p3.attvalue = 'RUP'
		--left join ProfiliUtenteAttrib p4 with(nolock) on p4.idpfu = a.idPfuInCharge and p4.dztNome = 'profilo' and p4.attvalue = 'ResponsabileAlbo'
		--left join ProfiliUtenteAttrib p5 with(nolock) on p5.idpfu = a.idPfuInCharge and p5.dztNome = 'profilo' and p5.attvalue = 'GestoreSDA'
		--left join ProfiliUtenteAttrib p6 with(nolock) on p6.idpfu = a.idPfuInCharge and p6.dztNome = 'profilo' and p6.attvalue = 'GestoreAlboLavori'
		--left join ProfiliUtenteAttrib p7 with(nolock) on p7.idpfu = a.idPfuInCharge and p7.dztNome = 'profilo' and p7.attvalue = 'GESTORE_ALBO_FORN'
		--left join ProfiliUtenteAttrib p8 with(nolock) on p8.idpfu = a.idPfuInCharge and p8.dztNome = 'profilo' and p8.attvalue = 'CONS_PREL_MERCATO'
		LEFT OUTER JOIN Document_bando band with(nolock) ON CTL_DOC.id = band.idheader
		--utente che ha in carico per le GARE deve essere il RUP per essere attivo il comando  “Invia al Richiedente” e “Pubblica”
		LEFT OUTER JOIN CTL_DOC_Value CV with(nolock) on  CV.IdHeader=a.id_origin and CV.dse_id='InfoTec_comune' and CV.row=0 
															and  CV.DZT_Name='UserRUP' and CV.Value=a.idPfuInCharge
		--utente che ha in carico per BANDO E BANDO_SDA deve essere il RUP per essere attivo il comando  “Invia al Richiedente” e “Pubblica”
		LEFT OUTER JOIN Document_Bando_Commissione CV2 with(nolock) on  CV2.IdHeader=a.id_origin and cv2.RuoloCommissione='15550' --and CV2.Idpfu=a.idPfuInCharge
		
		left outer join ctl_doc_value rup with (nolock)  on CTL_DOC.id = rup.idHeader and  rup.dzt_name = 'UserRup' and rup.dse_id = 'InfoTec_comune'
		
		



GO
