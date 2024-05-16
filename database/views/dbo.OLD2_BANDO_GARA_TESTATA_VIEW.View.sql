USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_BANDO_GARA_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[OLD2_BANDO_GARA_TESTATA_VIEW] as 

	select 
		b.idRow, b.idHeader, b.SoggettiAmmessi, b.ImportoBando, b.MaxNumeroIniziative, b.MaxFinanziabile, b.dataCreazione, b.DataEstenzioneInizio, b.DataEstenzioneFine, b.FAX, b.DataRiferimentoInizio, b.DataRiferimentoFine, b.DataPresentazioneRisposte, b.StatoBando, b.Ufficio, b.NumeroBUR, b.DataBUR, b.dgrN, b.dgrDel, b.TipoBando, b.TipoAppalto, b.RichiestaQuesito, b.ReceivedQuesiti, b.RecivedIstanze, b.MotivoEstensionePeriodo, b.ClasseIscriz, b.RichiediProdotti, b.ProceduraGara, b.TipoBandoGara, b.CriterioAggiudicazioneGara, b.ImportoBaseAsta, b.Iva, b.ImportoBaseAsta2, b.Oneri, b.CriterioFormulazioneOfferte, 
	
		case 
			when isnull(b.Concessione,'no')='si' then '0'
			else b.CalcoloAnomalia

		end as CalcoloAnomalia
	
		,b.OffAnomale, b.NumeroIndizione, b.DataIndizione, b.gg_QuesitiScadenza, b.DataTermineQuesiti, b.ClausolaFideiussoria, b.VisualizzaNotifiche, b.CUP, b.CIG, b.GG_OffIndicativa, b.HH_OffIndicativa, b.MM_OffIndicativa, b.DataScadenzaOffIndicativa, b.GG_Offerta, b.HH_Offerta, b.MM_Offerta, b.DataScadenzaOfferta, b.GG_PrimaSeduta, b.HH_PrimaSeduta, b.MM_PrimaSeduta, b.DataAperturaOfferte, b.TipoAppaltoGara, b.ProtocolloBando, b.DataRevoca, b.Conformita, b.Divisione_lotti, b.NumDec, b.DirezioneEspletante, b.DataProtocolloBando, b.ModalitadiPartecipazione, b.TipoIVA,
		case 
			--when b.ProceduraGara in ('15583','15479') then '0'
			when b.ProceduraGara in ('15479') then '0'
			when b.ProceduraGara = '15583' AND b.TipoBandoGara ='3' then '0'
			else b.EvidenzaPubblica 
		end as EvidenzaPubblica	 
		,b.Opzioni, b.Complex, b.RichiestaCampionatura, b.TipoGiudizioTecnico, b.TipoProceduraCaratteristica, b.GeneraConvenzione, b.ListaAlbi, b.Appalto_Verde, b.Acquisto_Sociale, b.Motivazione_Appalto_Verde, b.Motivazione_Acquisto_Sociale, b.Riferimento_Gazzetta, b.Data_Pubblicazione_Gazzetta, b.BaseAstaUnitaria,
	
		b.IdentificativoIniziativa, 
		b.ModalitaAnomalia_TEC, b.ModalitaAnomalia_ECO,
		b.DataTermineRispostaQuesiti, b.TipoSceltaContraente, b.TipoAccordoQuadro, b.TipoAggiudicazione, b.RegoleAggiudicatari, b.TipologiaDiAcquisto, b.Merceologia, b.CPV 
		, d.Azienda 
		, d.StrutturaAziendale
		, d.Body
		, v1.Value as ArtClasMerceologica 
		, v2.Value as UserRUP
		, d.Fascicolo,

		   case when b.TipoBandoGara = '3' then '' else ' EvidenzaPubblica ' end
		     
			 + case when mpidazimaster is null and b.TipoProceduraCaratteristica = 'RDO'  then ' GeneraConvenzione ' else '' end
			 + case when b.Divisione_lotti ='0' then ' ClausolaFideiussoria ' else '' end
			 -- se l'idpfu sul documento non è dell'agenzia e l'identificativoiniziativa è ' GARE ALTRI ENTI ' allora rendo il campo IdentificativoIniziativa non editabile
			 + case when isnull(b.IdentificativoIniziativa,'') = '9999' and p.pfuIdAzi <> 35152001 and IsAbilitatoModulo.SimogGgap <= 0 then ' IdentificativoIniziativa ' else '' end
			 + case when dbo.PARAMETRI('BANDO_GARA_AQ','BloccaCriteriEreditati','Editable','1',-1) = '0' then ' BloccaCriteriEreditati ' else '' end
			 + case when b.TipoProceduraCaratteristica = 'RilancioCompetitivo' then ' Richiesta_terna_subappalto UserRUP EnteProponente RupProponente ' else '' end
			 + case when isnull(b.Concessione,'no')='si' then ' CalcoloAnomalia ' else '' end
			 --+ case when cig.id is not null AND b.RichiestaCigSimog = 'si'  then ' UserRUP Divisione_lotti' else '' end 
			 + case when cig.id is not null AND b.RichiestaCigSimog = 'si'  then ' ' + dbo.PARAMETRI ('SIMOG','TIPO_RUP','DefaultValue','UserRUP',-1) + ' Divisione_lotti ' else '' end 
			 
			 --blocco il CIG se attivo INTEROP sulla GARA
			 + case when b.RichiestaCigSimog = 'si' or dbo.attivo_INTEROP_Gara(d.id)=1  then ' CIG ' else '' end

			 --blocco i campi se non previsto oppure sono su invito della ristretta o invito della negoziata
			 + case when  DM.vatValore_FT IS NULL  then ' EnteProponente  ' 
					when  b.TipoBandoGara = '3' AND isnull(d.LinkedDoc,0) <> 0   then ' EnteProponente RupProponente ' 
					else '' 
			   end

			+ case when dbo.IsTedActive(d.Azienda) = 0 then ' RichiestaTED ' else '' end

			+ case when SIMOG_RCig.EntiAbilitati <> '' AND CHARINDEX (',' + d.Azienda + ',', ',' + SIMOG_RCig.EntiAbilitati + ',') = 0 then ' RichiestaCigSimog '
				else ''
			   end

            -- Per GGAP: metto non editabiliu i campi per "Appalto PNRR/PNC" quando metto la spunta perchè i valori sono da prendere da GGAP.
            + CASE WHEN IsAbilitatoModulo.SimogGgap > 0
                     --THEN ' Appalto_PNRR  Motivazione_Appalto_PNRR  Appalto_PNC  Motivazione_Appalto_PNC  FLAG_PREVISIONE_QUOTA  QUOTA_FEMMINILE  QUOTA_GIOVANILE  ID_MOTIVO_DEROGA  FLAG_MISURE_PREMIALI  ID_MISURA_PREMIALE  '
                     THEN ' RichiestaCigSimog '
                   ELSE ''
              END

			--PER I RILANCI COMPETITIVI SE TROVA IL FLAG, BLOCCA IN TESTATA IL CAMPO "Criterio Formulazione Offerta Economica"
			--+ case when b.TipoProceduraCaratteristica = 'RilancioCompetitivo' and ISNULL(v4.value,'') =  'YES' then ' CriterioFormulazioneOfferte '
			--		else ''
			--	end
		   as Not_Editable

		, d.LinkedDoc
		, d.protocollogenerale
		, pda.id as idpda

		, '' as StatoProcedura

		,b.DataChiusura
		,d.Azienda as StazioneAppaltante
		, case 
			when d.TipoDoc = 'BANDO_SEMPLIFICATO'   then  b.DataScadenzaOffIndicativa 
			when d.TipoDoc = 'BANDO_GARA'   then  b.DataScadenzaOfferta 
			else  b.DataScadenzaOfferta 
			end as 	ScadenzaTerminiBando
		,dbo.getclassiIscrizListaAlbi(b.ListaAlbi) as ClasseIscriz_Bando
		,b.Num_max_lotti_offerti
		,B.RichiediDocumentazione
		,B.Richiesta_terna_subappalto

		, case when bs.TipoSceltaContraente = 'ACCORDOQUADRO' then 'yes' else 'no' end as AQ_RILANCIO_COMPETITVO
		, v3.Value as BloccaCriteriEreditati
		, b.Controllo_superamento_importo_gara
		, b.TipoSedutaGara
		, b.tiposoglia

		,case 
			when SUBSTRING(isnull( l.DZT_ValueDef , '' ) ,192,1)='0' then 'no'  --test del bit 192, il quale indica se sono attivi i parametri seduta virtuale sul cliente
			when b.TipoSedutaGara = 'virtuale' then 'si'
			when ( b.TipoSedutaGara IS NULL OR  b.TipoSedutaGara = 'null') and b.TipoProceduraCaratteristica <> 'RDO' then 'si'
			when ( b.TipoSedutaGara IS NULL OR  b.TipoSedutaGara = 'null') and b.TipoProceduraCaratteristica = 'RDO' then ''  
			else 'no'
		 end	as Scelta_Seduta_Virtuale

		 , b.RichiestaCigSimog
		 , v1_1.Value as TIPO_SOGGETTO_ART

		 , dbo.ISPBMInstalled() as ISPBMInstalled
		 , b.EnteProponente
		 , b.RupProponente
		 , b.Visualizzazione_Offerta_Tecnica
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
		 , b.ID_MOTIVO_DEROGA
		 , b.FLAG_MISURE_PREMIALI
		 , b.ID_MISURA_PREMIALE
		 , b.FLAG_PREVISIONE_QUOTA
		 , b.QUOTA_FEMMINILE
		 , b.QUOTA_GIOVANILE
		 , b.CATEGORIE_MERC
		 , b.CategoriaDiSpesa

		 --nuovi campi GenderEquality
		 ,b.GenderEquality
		 ,b.GenderEqualityMotivazione
		 ,case 
			when Y.id is null then 'no'
			else 'yes'
		  end as isActive_GROUP_PROGRAMMAZIONE_INIZIATIVA,
		  b.METODO_DI_CALCOLO_ANOMALIA,
		  b.ScontoDiRiferimento, 

		  case 
			 when isnull((select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI' and ',' + DZT_ValueDef + ',' like '%,AMPIEZZA_DI_GAMMA,%'), '') = '' then 'no'
			 else 'si'
		  end as PresenzaModuloAmpiezzaGamma,

		  b.pcp_UlterioriSommeNoRibasso,
		  b.pcp_SommeRipetizioni,
		  b.RegimeAllegerito

	from CTL_DOC d with(nolock)
		inner join Document_Bando b with(nolock) on d.id = b.idheader
		inner join profiliutente p with(nolock) on d.idpfu = p.idpfu
		left join marketplace m with(nolock) on m.mpidazimaster = p.pfuidazi
		left outer join CTL_DOC_Value v1 with(nolock) on b.idheader = v1.idheader and v1.dzt_name = 'ArtClasMerceologica' and v1.DSE_ID = 'ATTI'
		left outer join CTL_DOC_Value v1_1 with(nolock) on b.idheader = v1_1.idheader and v1_1.dzt_name = 'TIPO_SOGGETTO_ART' and v1_1.DSE_ID = 'ATTI'
		left outer join CTL_DOC_Value v2 with(nolock) on b.idheader = v2.idheader and v2.dzt_name = 'UserRUP' and v2.DSE_ID = 'InfoTec_comune'
	
		left join CTL_DOC_Value attocp with(nolock) on attocp.IdHeader = d.id and attocp.DSE_ID = 'PARAMETRI' and attocp.DZT_Name = 'AllegatoPerOCP'

		left outer join Document_Bando bs with(nolock) on d.LinkedDoc = bs.idheader and bs.idHeader <> 0

		-- PDA
		left outer join CTL_DOC pda with(nolock) on pda.linkeddoc = d.id and pda.deleted = 0 and pda.TipoDoc = 'PDA_MICROLOTTI'

		-- REVOCA
		left outer join ctl_doc rev with(nolock) on rev.tipodoc = 'REVOCA_BANDO' and rev.deleted = 0 and rev.LinkedDoc = d.id

		--BloccaCriteriEreditati
		left outer join CTL_DOC_Value v3 with(nolock) on b.idheader = v3.idheader and v3.dzt_name = 'BloccaCriteriEreditati' and v3.DSE_ID = 'InfoTec_comune'

		left outer join LIB_Dictionary l with(nolock) on l.DZT_Name='SYS_MODULI_RESULT' 

		--MODULO GROUP_PROGRAMMAZIONE_INIZIATIVE
		left join lib_dictionary Y with(nolock) on Y.dzt_name='SYS_MODULI_GRUPPI' and charindex(',GROUP_PROGRAMMAZIONE_INIZIATIVE,' , Y.DZT_ValueDef) > 0

		-- RICHIESTA CIG
		left join ctl_doc cig with(nolock) on cig.LinkedDoc = d.Id and cig.TipoDoc in ( 'RICHIESTA_CIG', 'RICHIESTA_SMART_CIG' ) and cig.Deleted = 0 and cig.StatoFunzionale <> 'Annullato'

		--ABILITAZIONE SET ENTE PROPONENTE
		left join DM_Attributi DM with(nolock) on DM.lnk=p.pfuIdAzi and DM.dztNome='SetEnteProponente' and vatValore_FT='1'

		-- recupera le regole da utilizzare per consentire la scelta del campo InversioneBuste
		--cross join ( select  dbo.PARAMETRI('BANDO_GARA_TESTATA','InversioneBusteRegole','DefaultValue','',-1) as InversioneBusteRegole ) as Reg 
		
		--PER I RILANCI COMPETITIVI SE TROVA IL FLAG, BLOCCA IN TESTATA IL CAMPO "Criterio Formulazione Offerta Economica"
		--left outer join CTL_DOC_Value v4 with(nolock) on b.idheader = v4.idheader and v4.dzt_name = 'CriterioFormulazioneOffertaEconomica' and v3.DSE_ID = 'BLOCCA'
		
		cross join ( select  dbo.PARAMETRI('GROUP_SIMOG','ENTI_ABILITATI','DefaultValue','',-1) as EntiAbilitati ) as SIMOG_RCig 
		
		--vado sulla ctl_doc_destinatari per gli affidamenti diretti semplificati
		left outer join ctl_Doc_destinatari DEST with (nolock) on DEST.idheader = D.id  and b.TipoProceduraCaratteristica ='AffidamentoSemplificato'
		
		cross join ( select  dbo.PARAMETRI('ATTIVA_MODULO','MODULO_APPALTO_PNRR_PNC','ATTIVA','NO',-1) as ATTIVA_MODULO_PNRR_PNC ) as X 	

        -- Per GGAP (non usato): metto non editabiliu i campi per "Appalto PNRR/PNC" quando metto la spunta perchè i valori sono da prendere da GGAP.
        CROSS JOIN ( SELECT ISNULL( CHARINDEX('SIMOG_GGAP', (select DZT_ValueDef from LIB_Dictionary WITH(NOLOCK) where DZT_Name = 'SYS_MODULI_GRUPPI')) , -1) AS SimogGgap ) AS IsAbilitatoModulo
GO
