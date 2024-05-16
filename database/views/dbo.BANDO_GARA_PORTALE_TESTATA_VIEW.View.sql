USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_GARA_PORTALE_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE view [dbo].[BANDO_GARA_PORTALE_TESTATA_VIEW] as 

select 
	b.idRow, b.idHeader, b.SoggettiAmmessi, b.ImportoBando, b.MaxNumeroIniziative, b.MaxFinanziabile, b.dataCreazione, b.DataEstenzioneInizio, b.DataEstenzioneFine, b.FAX, b.DataRiferimentoInizio, b.DataRiferimentoFine, b.DataPresentazioneRisposte, b.StatoBando, b.Ufficio, b.NumeroBUR, b.DataBUR, b.dgrN, b.dgrDel, b.TipoBando, b.TipoAppalto, b.RichiestaQuesito, b.ReceivedQuesiti, b.RecivedIstanze, b.MotivoEstensionePeriodo, b.ClasseIscriz, b.RichiediProdotti, b.ProceduraGara, b.TipoBandoGara, b.CriterioAggiudicazioneGara, b.ImportoBaseAsta, b.Iva, b.ImportoBaseAsta2, b.Oneri, b.CriterioFormulazioneOfferte, b.CalcoloAnomalia, b.OffAnomale, b.NumeroIndizione, b.DataIndizione, b.gg_QuesitiScadenza, b.DataTermineQuesiti, b.ClausolaFideiussoria, b.VisualizzaNotifiche, b.CUP, b.CIG, b.GG_OffIndicativa, b.HH_OffIndicativa, b.MM_OffIndicativa, b.DataScadenzaOffIndicativa, b.GG_Offerta, b.HH_Offerta, b.MM_Offerta, b.DataScadenzaOfferta, b.GG_PrimaSeduta, b.HH_PrimaSeduta, b.MM_PrimaSeduta, b.DataAperturaOfferte, b.TipoAppaltoGara, b.ProtocolloBando, b.DataRevoca, b.Conformita, b.Divisione_lotti, b.NumDec, b.DirezioneEspletante, b.DataProtocolloBando, b.ModalitadiPartecipazione, b.TipoIVA, b.EvidenzaPubblica, b.Opzioni, b.Complex, b.RichiestaCampionatura, b.TipoGiudizioTecnico, b.TipoProceduraCaratteristica, b.GeneraConvenzione, b.ListaAlbi, b.Appalto_Verde, b.Acquisto_Sociale, b.Motivazione_Appalto_Verde, b.Motivazione_Acquisto_Sociale, b.Riferimento_Gazzetta, b.Data_Pubblicazione_Gazzetta, b.BaseAstaUnitaria,
	
	b.IdentificativoIniziativa, 
	b.ModalitaAnomalia_TEC, b.ModalitaAnomalia_ECO,
	b.DataTermineRispostaQuesiti, b.TipoSceltaContraente, b.TipoAccordoQuadro, b.TipoAggiudicazione, b.RegoleAggiudicatari, b.TipologiaDiAcquisto, b.Merceologia, b.CPV 
	, d.Azienda 
	, d.StrutturaAziendale
	--, d.Body

	,case d.StatoFunzionale
			    when 'Revocato' then 'BANDO REVOCATO - ' + cast( d.Body as nvarchar(4000)) 
			    when 'InRettifica' then 'BANDO IN RETTIFICA - ' + cast( d.Body as nvarchar(4000)) 
				when 'Sospeso' then 'PROCEDURA SOSPESA - ' + cast( d.Body as nvarchar(4000)) 
				when 'InSospensione' then 'PROCEDURA IN SOSPENSIONE - ' + cast( d.Body as nvarchar(4000)) 
			    else   
					case 
						when isnull(v.linkeddoc,0) > 0 and V.TipoModifica =  'RIPRISTINO_GARA' then 'PROCEDURA RIPRISTINATA -  ' + cast( d.Body as nvarchar(4000)) 
						when isnull(v.linkeddoc,0) > 0 and V.TipoModifica <> 'RIPRISTINO_GARA' then  'BANDO RETTIFICATO - ' + cast( d.Body as nvarchar(4000)) 
					else
						cast( d.Body as nvarchar(4000)) 
					end		
	end as Body
	
	, v1.Value as ArtClasMerceologica 
	, v2.Value as UserRUP
	, d.Fascicolo

	, case when TipoBandoGara = '3' then '' else ' EvidenzaPubblica ' end
		+ case when mpidazimaster is null and b.TipoProceduraCaratteristica = 'RDO'  then ' GeneraConvenzione ' else '' end
		+ case when Divisione_lotti ='0' then ' ClausolaFideiussoria ' else '' end
		-- se l'idpfu sul documento non è dell'agenzia e l'identificativoiniziativa è ' GARE ALTRI ENTI ' allora rendo il campo IdentificativoIniziativa non editabile
		+ case when isnull(b.IdentificativoIniziativa,'') = '9999' and p.pfuIdAzi <> 35152001 then ' IdentificativoIniziativa ' else '' end
	   as Not_Editable

	,d.LinkedDoc
	,d.protocollogenerale
	, pda.id as idpda
	,case
		when d.statofunzionale = 'Revocato' then 'chiuso'
		when d.statodoc = 'Saved' then ''

		when getdate() <= b.DataScadenzaOfferta and d.TipoDoc = 'BANDO_GARA' then 'aperto'
		when getdate() <= b.DataScadenzaOffIndicativa and d.TipoDoc = 'BANDO_SEMPLIFICATO' then 'aperto'

		when getdate() > b.DataScadenzaOfferta and getdate() <= isnull( DataAggiudicazione , '3000-12-31' ) and  d.TipoDoc = 'BANDO_GARA'  then 'incorso'
		when getdate() > b.DataScadenzaOffIndicativa and getdate() <= isnull( DataAggiudicazione , '3000-12-31' ) and  d.TipoDoc = 'BANDO_SEMPLIFICATO'  then 'incorso'

		when getdate() > isnull( DataAggiudicazione , '3000-12-31' ) then 'chiuso'
		else ''
	end as StatoProcedura

	--, case 		when d.statofunzionale = 'Revocato' and b.DataChiusura is null then rev.DataInvio
	--			when d.statofunzionale = 'InEsame' and b.DataChiusura is null then DataAggiudicazione
	--			else b.DataChiusura  
	--   end as DataChiusura

	,b.DataChiusura

	,d.Azienda as StazioneAppaltante
	, case 
		when d.TipoDoc = 'BANDO_SEMPLIFICATO'   then  b.DataScadenzaOffIndicativa 
		when d.TipoDoc = 'BANDO_GARA'   then  b.DataScadenzaOfferta 
		else  b.DataScadenzaOfferta 
		end as 	ScadenzaTerminiBando
	,dbo.getclassiIscrizListaAlbi(ListaAlbi) as ClasseIscriz_Bando
	,b.Num_max_lotti_offerti
	,b.EnteProponente
	 , b.InversioneBuste
		 --, InversioneBusteRegole
		 ,b.GestioneQuote
		 ,b.Accordo_di_Servizio
		 ,b.Concessione
		 ,b.AppaltoInEmergenza
		 ,b.MotivazioneDiEmergenza
		 ,b.DestinatariNotifica
		 ,attocp.value as AllegatoPerOCP

		 , b.W9GACAM
		 , b.W9SISMA

		 , b.W9APOUSCOMP
		 , b.W3PROCEDUR
		 , b.W3PREINFOR
		 , b.W3TERMINE

		 , b.DESCRIZIONE_OPZIONI
		 , b.RichiestaTED
		 , DEST.IdAzi as  Destinatario_Azi 
		 
		 --campi pnrr/pnc
		 , lower(X.ATTIVA_MODULO_PNRR_PNC) as ATTIVA_MODULO_PNRR_PNC
		 , b.Appalto_PNRR_PNC
		 , b.Appalto_PNRR
		 , b.Motivazione_Appalto_PNRR
		 , b.Appalto_PNC
		 , b.Motivazione_Appalto_PNC

		 -- nuovi campi simog V. 3.04.7
		 --, b.ID_MOTIVO_DEROGA
		 --, b.FLAG_MISURE_PREMIALI
		 --, b.ID_MISURA_PREMIALE
		 --, b.FLAG_PREVISIONE_QUOTA
		 --, b.QUOTA_FEMMINILE
		 --, b.QUOTA_GIOVANILE
	
from CTL_DOC d WITH (NOLOCK) 
	inner join Document_Bando b  WITH (NOLOCK) on d.id = b.idheader
	inner join profiliutente p  WITH (NOLOCK) on d.idpfu = p.idpfu
	left join marketplace m  WITH (NOLOCK)  on m.mpidazimaster = p.pfuidazi
	left outer join CTL_DOC_Value v1  WITH (NOLOCK) on b.idheader = v1.idheader and v1.dzt_name = 'ArtClasMerceologica' and v1.DSE_ID = 'ATTI'
	left outer join CTL_DOC_Value v2  WITH (NOLOCK) on b.idheader = v2.idheader and v2.dzt_name = 'UserRUP' and v2.DSE_ID = 'InfoTec_comune'
	
	-- PDA
	left outer join CTL_DOC pda  WITH (NOLOCK) on pda.linkeddoc = d.id and pda.deleted = 0 and pda.TipoDoc = 'PDA_MICROLOTTI'

	-- comunicazione di aggiudicazione
	left outer join (  select min(datainvio ) as DataAggiudicazione , LinkedDoc 
							from CTL_DOC  WITH (NOLOCK) 
							where JumpCheck like '%ESITO_DEFINITIVO_MICROLOTTI' and TipoDoc in ('PDA_COMUNICAZIONE_GENERICA') and deleted=0 and StatoFunzionale='Inviato' 
							group by LinkedDoc
					) as dc on dc.LinkedDoc = pda.id

	-- REVOCA
	left outer join ctl_doc rev  WITH (NOLOCK)  on rev.tipodoc = 'REVOCA_BANDO' and rev.deleted = 0 and rev.LinkedDoc = d.id
    
	left  join (
			
			
					select d.linkedDoc , TipoDoc as TipoModifica  from ctl_doc d with(nolock) 
						inner join ( 
										Select max(id) as ID_DOC ,  linkedDoc from ctl_doc  with(nolock) where tipodoc IN ('RETTIFICA_BANDO','PROROGA_BANDO','RETTIFICA_GARA','PROROGA_GARA'  , 'RIPRISTINO_GARA'  ) and Statodoc ='Sended' group by linkedDoc  
										) as M on M.id_DOC = d.id
			
					) V on V.LinkedDoc=d.id

     --PROROGA
	--left  join (Select distinct(linkedDoc), deleted as cancellato from ctl_doc  WITH (NOLOCK) where tipodoc='PROROGA_GARA' and statofunzionale = 'Inviato' ) V on V.LinkedDoc=d.id and V.cancellato = 0 
	
	--RETTIFICA
	--left  join (Select distinct(linkedDoc), deleted as cancellato from ctl_doc  WITH (NOLOCK) where tipodoc='RETTIFICA_GARA' and statofunzionale = 'Inviato' ) Z on Z.LinkedDoc=d.id and Z.cancellato = 0
	left join CTL_DOC_Value attocp with(nolock) on attocp.IdHeader = d.id and attocp.DSE_ID = 'PARAMETRI' and attocp.DZT_Name = 'AllegatoPerOCP'
	--vado sulla ctl_doc_destinatari per gli affidamenti diretti semplificati
	left outer join ctl_Doc_destinatari DEST with (nolock) on DEST.idheader = D.id  and b.TipoProceduraCaratteristica ='AffidamentoSemplificato'
	cross join ( select  dbo.PARAMETRI('ATTIVA_MODULO','MODULO_APPALTO_PNRR_PNC','ATTIVA','NO',-1) as ATTIVA_MODULO_PNRR_PNC ) as X 	











GO
