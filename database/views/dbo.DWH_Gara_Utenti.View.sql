USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DWH_Gara_Utenti]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[DWH_Gara_Utenti] as 
	
	--- Utente Compilatore della Gara (PuntoIstruttore)
	select 
	
			Fascicolo , 
			Protocollo as [Codice Procedura di Gara],
			g.IdPfu as idUtente , 
			'PuntoIstruttore' as Ruolo,
			p.pfuCodiceFiscale as [CodiceFiscaleUtente],
			azilog as [Codice Ente]

		from CTL_DOC g with(nolock) 
			inner join ProfiliUtente p with(nolock) on p.IdPfu = g.IdPfu
			inner join Aziende a with(nolock) on a.IdAzi = g.Azienda

		WHERE g.tipodoc in ( 'bando_gara' ,'BANDO_SEMPLIFICATO')
			   AND g.deleted = 0
			   AND g.statodoc = 'sended'

	union 

	--- Utenti Commissione della Gara ()
	select 
	
		g.Fascicolo , 
		g.Protocollo as [Codice Procedura di Gara],
		g.IdPfu as idUtente , 
		case 
			when cu.TipoCommissione = 'A' then 'SeggioDiGara'  
			when cu.TipoCommissione = 'G' then 'CommissioneGiudicatrice'  
			when cu.TipoCommissione = 'C' then 'CommissioneValutazioneEconomica'  
		end 
		+ '_' + replace( v.DMV_DescML , ' ' , '' ) 
		as Ruolo,
		p.pfuCodiceFiscale as [CodiceFiscaleUtente],
		azilog as [Codice Ente]

		from CTL_DOC g with(nolock) 
			inner join ProfiliUtente p with(nolock) on p.IdPfu = g.IdPfu
			inner join Aziende a with(nolock) on a.IdAzi = g.Azienda
			inner join CTL_DOC c with(nolock) on c.LinkedDoc = g.Id and c.TipoDoc = 'COMMISSIONE_PDA' and c.StatoFunzionale in (  'Pubblicato' , 'Annullato' )
			inner join Document_CommissionePda_Utenti cu with(nolock) on cu.IdHeader= c.Id 
			inner join LIB_DomainValues v with(nolock) on v.DMV_DM_ID = 'ruolocommissione' and v.DMV_Cod = cu.RuoloCommissione

		WHERE g.tipodoc in ( 'bando_gara' ,'BANDO_SEMPLIFICATO')
				AND g.deleted = 0
				AND g.statodoc = 'sended'
	
	union 
		
	--- Utente RUP della Gara (RUP)
	select 
	
		Fascicolo , 
		Protocollo as [Codice Procedura di Gara],
		GU.value as idUtente , 
		'RUP' as Ruolo,
		p.pfuCodiceFiscale as [CodiceFiscaleUtente],
		azilog as [Codice Ente]

		from CTL_DOC g with(nolock) 
			inner join ctl_doc_value GU with(nolock) on GU.idheader = G.id and GU.dse_id = 'InfoTec_comune' and GU.DZT_Name ='UserRUP'
			inner join ProfiliUtente p with(nolock) on p.IdPfu = GU.value
			inner join Aziende a with(nolock) on a.IdAzi = g.Azienda

		WHERE g.tipodoc in ( 'bando_gara' ,'BANDO_SEMPLIFICATO')
				AND g.deleted = 0
				AND g.statodoc = 'sended'
	
	union 
		
	--- Utente RUP proponente della Gara (RupProponente)
	select 
	
		Fascicolo , 
		Protocollo as [Codice Procedura di Gara],
		GU.RupProponente as idUtente , 
		'RupProponente' as Ruolo,
		p.pfuCodiceFiscale as [CodiceFiscaleUtente],
		azilog as [Codice Ente]

		from CTL_DOC g with(nolock) 
			inner join document_bando GU with(nolock) on GU.idheader = G.id 
			inner join ProfiliUtente p with(nolock) on p.IdPfu = GU.RupProponente
			inner join Aziende a with(nolock) on a.IdAzi = g.Azienda

		WHERE g.tipodoc in ( 'bando_gara' ,'BANDO_SEMPLIFICATO')
				AND g.deleted = 0
				AND g.statodoc = 'sended'
	
	union 

	--- Riferimenti della gara (Riferimenti_.....)
	select 
	
		g.Fascicolo , 
		g.Protocollo as [Codice Procedura di Gara],
		R.idPfu as idUtente , 
		'Riferimenti_' + replace( v.DMV_DescML , ' ' , '' )  as Ruolo,
		p.pfuCodiceFiscale as [CodiceFiscaleUtente],
		azilog as [Codice Ente]

		from CTL_DOC g with(nolock) 
			inner join Document_Bando_Riferimenti R with(nolock) on R.IdHeader= g.Id 
			inner join LIB_DomainValues v with(nolock) on v.DMV_DM_ID = 'RuoloRiferimenti' and v.DMV_Cod = R.RuoloRiferimenti 
			inner join ProfiliUtente p with(nolock) on p.IdPfu = R.IdPfu
			inner join Aziende a with(nolock) on a.IdAzi = g.Azienda
		
		
		WHERE g.tipodoc in ( 'bando_gara' ,'BANDO_SEMPLIFICATO')
				AND g.deleted = 0
				AND g.statodoc = 'sended'
	
	union 

	--- CompilatoreOfferta
	select 
	
		g.Fascicolo , 
		g.Protocollo as [Codice Procedura di Gara],
		o.IdPfu as idUtente , 
		'Compilatore_' + O.TipoDoc as Ruolo,
		p.pfuCodiceFiscale as [CodiceFiscaleUtente],
		azilog as [Codice Ente]

	from CTL_DOC g with(nolock) 
		inner join ctl_doc O with(nolock)  on O.LinkedDoc = g.id and O.TipoDoc in  ('OFFERTA', 'DOMANDA_PARTECIPAZIONE' , 'MANIFESTAZIONE_INTERESSE') 
												and O.statodoc='Sended' and O.Deleted =0 
		inner join ProfiliUtente p with(nolock) on p.IdPfu = O.IdPfu
		inner join Aziende a with(nolock) on a.IdAzi = g.Azienda

	WHERE g.tipodoc in ( 'bando_gara' ,'BANDO_SEMPLIFICATO')
			AND g.deleted = 0
			AND g.statodoc = 'sended'

	union 

	--- Quesiti Domanda
	select 
		distinct 
		g.Fascicolo , 
		g.Protocollo as [Codice Procedura di Gara],
		c.UtenteDomanda as idUtente , 
		'Quesiti_UtenteDomanda' as Ruolo,
		p.pfuCodiceFiscale as [CodiceFiscaleUtente],
		azilog as [Codice Ente]

	from CTL_DOC g with(nolock) 
		inner join document_chiarimenti C with (nolock) on C.ID_ORIGIN = G.id and isnull(C.protocol,'') <> ''
		inner join ProfiliUtente p with(nolock) on p.IdPfu = c.UtenteDomanda 
		inner join Aziende a with(nolock) on a.IdAzi = g.Azienda
		--dubbio le domande dall'interno ???? utentedomanda = -20 che faccio?
	WHERE g.tipodoc in ( 'bando_gara' ,'BANDO_SEMPLIFICATO')
			AND g.deleted = 0
			AND g.statodoc = 'sended'
	
	union 
	
	--- Quesiti Risposta
	select 
		distinct
		g.Fascicolo , 
		g.Protocollo as [Codice Procedura di Gara],
		c.UtenteRisposta as idUtente , 
		'Quesiti_UtenteRisposta' as Ruolo,
		p.pfuCodiceFiscale as [CodiceFiscaleUtente],
		azilog as [Codice Ente]

	from CTL_DOC g with(nolock) 
		inner join document_chiarimenti C with (nolock) on C.ID_ORIGIN = G.id and isnull(C.ProtocolRispostaQuesito,'') <> ''
		inner join ProfiliUtente p with(nolock) on p.IdPfu = c.UtenteRisposta
		inner join Aziende a with(nolock) on a.IdAzi = g.Azienda
		
	WHERE g.tipodoc in ( 'bando_gara' ,'BANDO_SEMPLIFICATO')
			AND g.deleted = 0
			AND g.statodoc = 'sended'

	union

	--cambio rup (RUP)
	select 
	
		g.Fascicolo , 
		g.Protocollo as [Codice Procedura di Gara],
		p.idpfu as idUtente , 
		'RUP' as Ruolo,
		p.pfuCodiceFiscale as [CodiceFiscaleUtente],
		azilog as [Codice Ente]

	from 
		CTL_DOC g with(nolock) 
			inner join ctl_doc SR with(nolock)  on SR.LinkedDoc = G.id and SR.TipoDoc = 'SOSTITUZIONE_RUP' and SR.StatoDoc = 'Sended' and SR.Deleted=0
			inner join ctl_doc_value with(nolock)  on IdHeader = SR.id and dse_id='TESTATA' and DZT_Name = 'UserRUP'
			inner join ProfiliUtente p with(nolock) on p.IdPfu = value
			inner join Aziende a with(nolock) on a.IdAzi = g.Azienda

	WHERE 
		g.tipodoc in ( 'bando_gara' ,'BANDO_SEMPLIFICATO') AND g.deleted = 0 AND g.statodoc = 'sended'

	union 

	--cambio riferimenti (Riferimenti)
	select 
	
		g.Fascicolo , 
		g.Protocollo as [Codice Procedura di Gara],
		R.idPfu as idUtente , 
		'Riferimenti_' + replace( v.DMV_DescML , ' ' , '' )  as Ruolo,
		p.pfuCodiceFiscale as [CodiceFiscaleUtente],
		azilog as [Codice Ente]

		from CTL_DOC g with(nolock) 
			inner join ctl_doc BM with(nolock) on BM.LinkedDoc = G.id and BM.TipoDoc='BANDO_MODIFICA'
			inner join Document_Bando_Riferimenti R with(nolock) on R.IdHeader= BM.Id 
			inner join LIB_DomainValues v with(nolock) on v.DMV_DM_ID = 'RuoloRiferimenti' and v.DMV_Cod = R.RuoloRiferimenti 
			inner join ProfiliUtente p with(nolock) on p.IdPfu = R.IdPfu
			inner join Aziende a with(nolock) on a.IdAzi = g.Azienda
		
		
		WHERE g.tipodoc in ( 'bando_gara' ,'BANDO_SEMPLIFICATO')
				AND g.deleted = 0
				AND g.statodoc = 'sended'

GO
