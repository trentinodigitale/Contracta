USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_BANDO_SEMPLIFICATO_TESTATA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[OLD2_BANDO_SEMPLIFICATO_TESTATA] as

	select  --d.* ,
       d.[Id], d.[IdPfu], d.[IdDoc], d.[TipoDoc], d.[StatoDoc], d.[Data], 
		d.[Protocollo], d.[PrevDoc], d.[Deleted], d.[Titolo], 
		case when isnull(v.linkeddoc,0) > 0 or isnull(Z.linkeddoc,0) > 0
			then 'Bando Rettificato - ' + cast( d.Body as nvarchar(4000)) 
			else
			cast( d.Body as nvarchar(4000)) 
		end
		as Body,

		d.[Azienda], d.[StrutturaAziendale], d.[DataInvio], 
		d.[DataScadenza], d.[ProtocolloRiferimento], d.[ProtocolloGenerale], 
		d.[Fascicolo], d.[Note], d.[DataProtocolloGenerale], d.[LinkedDoc], 
		d.[SIGN_HASH], d.[SIGN_ATTACH], d.[SIGN_LOCK], d.[JumpCheck], d.[StatoFunzionale], 
		d.[Destinatario_User], d.[Destinatario_Azi], d.[RichiestaFirma], d.[NumeroDocumento], 
		d.[DataDocumento], d.[Versione], d.[VersioneLinkedDoc], d.[GUID], d.[idPfuInCharge], 
		d.[CanaleNotifica], d.[URL_CLIENT], d.[Caption], d.[FascicoloGenerale],
		s.idRow, s.idHeader, s.SoggettiAmmessi, s.ImportoBando, s.MaxNumeroIniziative, s.MaxFinanziabile, s.dataCreazione, s.DataEstenzioneInizio, s.DataEstenzioneFine, s.FAX, s.DataRiferimentoInizio, s.DataRiferimentoFine, s.DataPresentazioneRisposte, s.StatoBando, s.Ufficio, s.NumeroBUR, s.DataBUR, s.dgrN, s.dgrDel, s.TipoBando, s.TipoAppalto, s.RichiestaQuesito, s.ReceivedQuesiti, s.RecivedIstanze, s.MotivoEstensionePeriodo, s.ClasseIscriz, s.RichiediProdotti, s.ProceduraGara, s.TipoBandoGara, s.CriterioAggiudicazioneGara, s.ImportoBaseAsta, s.Iva, s.ImportoBaseAsta2, s.Oneri, s.CriterioFormulazioneOfferte, s.CalcoloAnomalia, s.OffAnomale, s.NumeroIndizione, s.DataIndizione, s.gg_QuesitiScadenza, s.DataTermineQuesiti, s.ClausolaFideiussoria, s.VisualizzaNotifiche, s.CUP, s.CIG, s.GG_OffIndicativa, s.HH_OffIndicativa, s.MM_OffIndicativa, s.DataScadenzaOffIndicativa, s.GG_Offerta, s.HH_Offerta, s.MM_Offerta, s.DataScadenzaOfferta, s.GG_PrimaSeduta, s.HH_PrimaSeduta, s.MM_PrimaSeduta, s.DataAperturaOfferte, s.TipoAppaltoGara, s.ProtocolloBando, s.DataRevoca, s.Conformita, s.Divisione_lotti, s.NumDec, s.DirezioneEspletante, s.DataProtocolloBando, s.ModalitadiPartecipazione, s.TipoIVA, s.EvidenzaPubblica, s.Opzioni, s.Complex, s.RichiestaCampionatura, s.TipoGiudizioTecnico, s.TipoProceduraCaratteristica, s.GeneraConvenzione, s.ListaAlbi, s.Appalto_Verde, s.Acquisto_Sociale, s.Motivazione_Appalto_Verde, s.Motivazione_Acquisto_Sociale, s.Riferimento_Gazzetta, s.Data_Pubblicazione_Gazzetta, s.BaseAstaUnitaria, s.IdentificativoIniziativa, s.DataTermineRispostaQuesiti, s.TipoSceltaContraente, s.TipoAccordoQuadro, s.TipoAggiudicazione, s.RegoleAggiudicatari, s.TipologiaDiAcquisto, s.Merceologia, s.CPV 

		,	b.Body as DescrizioneRichiesta
		, v2.Value as UserRUP
		,BS.RichiediProdotti as  RichiediProdottiSDA
		, 
			case 
				when d.StatoFunzionale='InApprove'  then
					case 
						when s.gg_QuesitiScadenza <> 0 then ' DataTermineQuesiti  DataScadenzaOfferta  DataAperturaOfferte  DataScadenzaOffIndicativa TipoIVA DataTermineQuesiti  Altro '
						else '  DataScadenzaOfferta  DataAperturaOfferte DataScadenzaOffIndicativa TipoIVA DataTermineQuesiti Altro '
					end 
				when d.StatoFunzionale='ProntoPerInviti' then '  DataTermineQuesiti  DataScadenzaOffIndicativa  '
				else '' 
			end 

			+ case when isnull(s.IdentificativoIniziativa,'') = '9999' and pu.pfuIdAzi <> 35152001 then ' IdentificativoIniziativa ' else '' end
			+ case when s.RichiestaCigSimog = 'si' then ' CIG ' else '' end
			+ case when cig.id is not null  then ' UserRUP ' else '' end 
			+ case when DM.vatValore_FT IS NULL then ' EnteProponente RupProponente ' else '' end

			+ case when SIMOG_RCig.EntiAbilitati <> '' AND CHARINDEX (',' + d.Azienda + ',', ',' + SIMOG_RCig.EntiAbilitati + ',') = 0 then ' RichiestaCigSimog '
				else ''
			   end


		  as NotEditable

		, pda.id as idpda
	
		,case
			when d.statofunzionale = 'Revocato' then 'chiuso'
			when d.statodoc = 'Saved' then ''

			when getdate() <= s.DataScadenzaOfferta and d.TipoDoc = 'BANDO_GARA' then 'aperto'
			when getdate() <= s.DataScadenzaOffIndicativa and d.TipoDoc = 'BANDO_SEMPLIFICATO' then 'aperto'

			when getdate() > s.DataScadenzaOfferta and getdate() <= isnull( s.DataChiusura , '3000-12-31' ) and  d.TipoDoc = 'BANDO_GARA'  then 'incorso'
			when getdate() > s.DataScadenzaOffIndicativa and getdate() <= isnull( s.DataChiusura , '3000-12-31' ) and  d.TipoDoc = 'BANDO_SEMPLIFICATO'  then 'incorso'

			when getdate() > isnull( s.DataChiusura , '3000-12-31' ) then 'chiuso'
			else ''
		end as StatoProcedura

		--,'' as StatoProcedura

		, case 		when d.statofunzionale = 'Revocato' and s.DataChiusura is null then rev.DataInvio
					--when d.statofunzionale = 'InEsame' and s.DataChiusura is null then DataAggiudicazione
					else s.DataChiusura  
		   end as DataChiusura

		, d.Azienda as StazioneAppaltante
		,case when ISNULL(rev2.statofunzionale,'') = 'Approved' then 'si' else 'no' end as BANDO_REVOCATO

		,--coalesce(am.value,cod.Value,'') 
		 '' as Ambito

		,cvcat.value as elenco_categorie_sda
		, criterio_scelt.value as Criteriio_scelta_fornitori
		, elenco_cat.value as Categorie_Merceologiche
		,s.Num_max_lotti_offerti
		,s.Richiesta_terna_subappalto
		 , s.ModalitaAnomalia_ECO
		 , s.ModalitaAnomalia_TEC	 
		 ,ISNULL(s.TipoSedutaGara,'NESSUNA_SELEZIONE') as TipoSedutaGara
		 ,case
				when SUBSTRING(isnull( l.DZT_ValueDef , '' ) ,192,1)='0' then 'no'  --test del bit 192, il quale indica se sono attivi i parametri seduta virtuale sul cliente
				when s.TipoSedutaGara = 'virtuale' then 'si'
				when ( s.TipoSedutaGara IS NULL OR  s.TipoSedutaGara = 'null')  then 'si'
				else 'no'
		  end	as Scelta_Seduta_Virtuale

		  , s.RichiestaCigSimog

		  , v1_1.Value as TIPO_SOGGETTO_ART

		  , dbo.ISPBMInstalled() as ISPBMInstalled
		  , s.EnteProponente
		  , s.RupProponente
		  , cvliv.Value as Livello_Categorie_Merceologiche
		  , cvele.Value as Elenco_Categorie_Merceologiche
		  ,s.Visualizzazione_Offerta_Tecnica
		  ,s.Accordo_di_Servizio
		  ,s.AppaltoInEmergenza
		  ,s.MotivazioneDiEmergenza
		  , attocp.value as AllegatoPerOCP
		  ,b.StatoFunzionale as StatoFunzionaleSDA
		  ,s.tiposoglia

		  , s.W9GACAM
		  , s.W9SISMA

		  , s.W9APOUSCOMP
		  , s.W3PROCEDUR
		  , s.W3PREINFOR
		  , s.W3TERMINE

		  , s.DESCRIZIONE_OPZIONI
		  , s.RichiestaTED

		  --campi pnrr/pnc
		  , lower(X.ATTIVA_MODULO_PNRR_PNC) as ATTIVA_MODULO_PNRR_PNC
		 , s.Appalto_PNRR_PNC
		 , s.Appalto_PNRR
		 , s.Motivazione_Appalto_PNRR
		 , s.Appalto_PNC
		 , s.Motivazione_Appalto_PNC

		 -- nuovi campi simog V. 3.04.7
		 , s.ID_MOTIVO_DEROGA
		 , s.FLAG_MISURE_PREMIALI
		 , s.ID_MISURA_PREMIALE
		 , s.FLAG_PREVISIONE_QUOTA
		 , s.QUOTA_FEMMINILE
		 , s.QUOTA_GIOVANILE
		
		 , case 
			when AG.id is null then 'no'
			else 'si'
		  end as PresenzaModuloAmpiezzaGamma,

		  s.CategoriaDiSpesa,

		  s.pcp_UlterioriSommeNoRibasso,
		  s.pcp_SommeRipetizioni

	from CTL_DOC  d  with(nolock)
			inner join dbo.Document_Bando s with(nolock) on id = idheader
			left join profiliutente pu  with(nolock) on pu.idpfu = d.idpfu 
			inner join CTL_DOC b  with(nolock) on b.id = d.linkedDoc
			inner join dbo.Document_Bando BS  with(nolock) on BS.idheader=B.id
			left outer join CTL_DOC_Value v2  with(nolock) on s.idheader = v2.idheader and v2.dzt_name = 'UserRUP' and v2.DSE_ID = 'InfoTec_comune'

			left join CTL_DOC_Value attocp with(nolock) on attocp.IdHeader = d.id and attocp.DSE_ID = 'PARAMETRI' and attocp.DZT_Name = 'AllegatoPerOCP'

			-- PDA
			left outer join CTL_DOC pda  with(nolock) on pda.linkeddoc = d.id and pda.deleted = 0 and pda.TipoDoc = 'PDA_MICROLOTTI'

			-- REVOCA SEMP
			left outer join ctl_doc rev  with(nolock) on rev.tipodoc = 'REVOCA_BANDO' and rev.deleted = 0 and rev.LinkedDoc = d.id

			-- REVOCA SDA
			left outer join ctl_doc rev2  with(nolock) on rev2.tipodoc = 'REVOCA_BANDO' and rev2.deleted = 0 and rev2.LinkedDoc = d.linkeddoc and rev2.statofunzionale = 'Approved'

			--- recupero le categorie merceologiche selezionate sullo sda 
			left outer join ctl_doc_value cvcat  with(nolock) on  cvcat.idHeader=d.linkeddoc and  cvcat.dzt_name = 'Categorie_Merceologiche' and cvcat.dse_id = 'TESTATA_PRODOTTI' 
			left outer join ctl_doc_value cvele  with(nolock) on  cvele.idHeader=d.linkeddoc and  cvele.dzt_name = 'Elenco_Categorie_Merceologiche' and cvele.dse_id = 'TESTATA_PRODOTTI' 
			left outer join ctl_doc_value cvliv  with(nolock) on  cvliv.idHeader=d.linkeddoc and  cvliv.dzt_name = 'Livello_Categorie_Merceologiche' and cvliv.dse_id = 'TESTATA_PRODOTTI' 
			left outer join CTL_DOC_Value elenco_cat  with(nolock) on s.idheader = elenco_cat.idheader and elenco_cat.dzt_name = 'Categorie_Merceologiche' and elenco_cat.DSE_ID = 'TESTATA_PRODOTTI'
			left outer join CTL_DOC_Value criterio_scelt  with(nolock) on s.idheader = criterio_scelt.idheader and criterio_scelt.dzt_name = 'Criteriio_scelta_fornitori' and criterio_scelt.DSE_ID = 'TESTATA_PRODOTTI'

			left outer join CTL_DOC_Value am  with(nolock) on am.idheader = d.id and am.DSE_ID = 'TESTATA_PRODOTTI' and am.DZT_Name = 'Ambito'
			left outer join LIB_Dictionary l with(nolock) on l.DZT_Name='SYS_MODULI_RESULT' 

			left join LIB_Dictionary AG with(nolock) on AG.DZT_Name='SYS_MODULI_GRUPPI'  and CHARINDEX(',AMPIEZZA_DI_GAMMA,', ',' + AG.DZT_ValueDef + ',' ) > 0

			left outer join CTL_DOC_Value v1_1 with(nolock) on s.idheader = v1_1.idheader and v1_1.dzt_name = 'TIPO_SOGGETTO_ART' and v1_1.DSE_ID = 'ATTI'

			-- RICHIESTA CIG
			left join ctl_doc cig with(nolock) on cig.LinkedDoc = d.Id and cig.TipoDoc in ( 'RICHIESTA_CIG', 'RICHIESTA_SMART_CIG' ) and cig.Deleted = 0 and cig.StatoFunzionale <> 'Annullato'
			
			left  join (Select distinct(linkedDoc), deleted as cancellato from ctl_doc with(nolock) where tipodoc='PROROGA_GARA' and statofunzionale = 'Inviato') V on V.LinkedDoc=d.id and V.cancellato = 0 
			left  join (Select distinct(linkedDoc), deleted as cancellato from ctl_doc with(nolock) where tipodoc='RETTIFICA_GARA' and statofunzionale = 'Inviato') Z on Z.LinkedDoc=d.id and Z.cancellato = 0
			--ABILITAZIONE SET ENTE PROPONENTE
			left join DM_Attributi DM with(nolock) on DM.lnk=pu.pfuIdAzi and DM.dztNome='SetEnteProponente' and vatValore_FT='1'
			
			cross join ( select  dbo.PARAMETRI('GROUP_SIMOG','ENTI_ABILITATI','DefaultValue','',-1) as EntiAbilitati ) as SIMOG_RCig 
			cross join ( select  dbo.PARAMETRI('ATTIVA_MODULO','MODULO_APPALTO_PNRR_PNC','ATTIVA','NO',-1) as ATTIVA_MODULO_PNRR_PNC ) as X 	
GO
