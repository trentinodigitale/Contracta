USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TEMPLATE_GARA_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TEMPLATE_GARA_TESTATA_VIEW]
AS
SELECT b.idRow
  , b.idHeader
  , b.SoggettiAmmessi
  , b.ImportoBando
  , b.MaxNumeroIniziative
  , b.MaxFinanziabile
  , b.dataCreazione
  , b.DataEstenzioneInizio
  , b.DataEstenzioneFine
  , b.FAX
  , b.DataRiferimentoInizio
  , b.DataRiferimentoFine
  , b.DataPresentazioneRisposte
  , b.StatoBando
  , b.Ufficio
  , b.NumeroBUR
  , b.DataBUR
  , b.dgrN
  , b.dgrDel
  , b.TipoBando
  , b.TipoAppalto
  , b.RichiestaQuesito
  , b.ReceivedQuesiti
  , b.RecivedIstanze
  , b.MotivoEstensionePeriodo
  , b.ClasseIscriz
  , b.RichiediProdotti
  , b.ProceduraGara
  , b.TipoBandoGara
  , b.CriterioAggiudicazioneGara
  , b.ImportoBaseAsta
  , b.Iva
  , b.ImportoBaseAsta2
  , b.Oneri
  , b.CriterioFormulazioneOfferte
  , CASE 
      WHEN isnull(b.Concessione, 'no') = 'si' THEN '0'
      ELSE b.CalcoloAnomalia
    END AS CalcoloAnomalia
  , b.OffAnomale
  , b.NumeroIndizione
  , b.DataIndizione
  , b.gg_QuesitiScadenza
  , b.DataTermineQuesiti
  , b.ClausolaFideiussoria
  , b.VisualizzaNotifiche
  , b.CUP
  , b.CIG
  , b.GG_OffIndicativa
  , b.HH_OffIndicativa
  , b.MM_OffIndicativa
  , b.DataScadenzaOffIndicativa
  , b.GG_Offerta
  , b.HH_Offerta
  , b.MM_Offerta
  , b.DataScadenzaOfferta
  , b.GG_PrimaSeduta
  , b.HH_PrimaSeduta
  , b.MM_PrimaSeduta
  , b.DataAperturaOfferte
  , b.TipoAppaltoGara
  , b.ProtocolloBando
  , b.DataRevoca
  , b.Conformita
  , b.Divisione_lotti
  , b.NumDec
  , b.DirezioneEspletante
  , b.DataProtocolloBando
  , b.ModalitadiPartecipazione
  , b.TipoIVA
  , CASE 
      --when b.ProceduraGara in ('15583','15479') then '0'
      WHEN b.ProceduraGara IN ('15479') THEN '0'
      WHEN b.ProceduraGara = '15583' AND b.TipoBandoGara = '3' THEN '0'
      ELSE b.EvidenzaPubblica
    END AS EvidenzaPubblica
  , b.Opzioni
  , b.Complex
  , b.RichiestaCampionatura
  , b.TipoGiudizioTecnico
  , b.TipoProceduraCaratteristica
  , b.GeneraConvenzione
  , b.ListaAlbi
  , b.Appalto_Verde
  , b.Acquisto_Sociale
  , b.Motivazione_Appalto_Verde
  , b.Motivazione_Acquisto_Sociale
  , b.Riferimento_Gazzetta
  , b.Data_Pubblicazione_Gazzetta
  , b.BaseAstaUnitaria
  , b.IdentificativoIniziativa
  , b.ModalitaAnomalia_TEC
  , b.ModalitaAnomalia_ECO
  , b.DataTermineRispostaQuesiti
  , b.TipoSceltaContraente
  , b.TipoAccordoQuadro
  , b.TipoAggiudicazione
  , b.RegoleAggiudicatari
  , b.TipologiaDiAcquisto
  , b.Merceologia
  , b.CPV
  , NULL AS Azienda -- d.Azienda
  , d.StrutturaAziendale
  , d.Body
  , v1.Value AS ArtClasMerceologica
  , NULL AS UserRUP -- v2.Value AS UserRUP
  , d.Fascicolo
  , CASE WHEN b.TipoBandoGara = '3' THEN '' ELSE ' EvidenzaPubblica ' END
    + CASE WHEN mpidazimaster IS NULL AND b.TipoProceduraCaratteristica = 'RDO' THEN ' GeneraConvenzione ' ELSE '' END
    + CASE WHEN b.Divisione_lotti = '0' THEN ' ClausolaFideiussoria ' ELSE ''END
    -- se l'idpfu sul documento non è dell'agenzia e l'identificativoiniziativa è ' GARE ALTRI ENTI ' allora rendo il campo IdentificativoIniziativa non editabile
    + CASE WHEN isnull(b.IdentificativoIniziativa, '') = '9999' AND p.pfuIdAzi <> 35152001 THEN ' IdentificativoIniziativa ' ELSE '' END
    + CASE WHEN dbo.PARAMETRI('BANDO_GARA_AQ', 'BloccaCriteriEreditati', 'Editable', '1', - 1) = '0' THEN ' BloccaCriteriEreditati ' ELSE '' END
    + CASE WHEN b.TipoProceduraCaratteristica = 'RilancioCompetitivo' THEN ' Richiesta_terna_subappalto UserRUP EnteProponente RupProponente ' ELSE '' END
    + CASE WHEN isnull(b.Concessione, 'no') = 'si' THEN ' CalcoloAnomalia ' ELSE '' END
    -- + case when cig.id is not null AND b.RichiestaCigSimog = 'si'  then ' UserRUP Divisione_lotti' else '' end 
    + CASE WHEN cig.id IS NOT NULL AND b.RichiestaCigSimog = 'si' THEN ' ' + dbo.PARAMETRI('SIMOG', 'TIPO_RUP', 'DefaultValue', 'UserRUP', - 1) + ' Divisione_lotti ' ELSE '' END
    + CASE WHEN b.RichiestaCigSimog = 'si' THEN ' CIG ' ELSE '' END
    --blocco i campi se non previsto oppure sono su invito della ristretta o invito della negoziata
    + CASE WHEN DM.vatValore_FT IS NULL THEN ' EnteProponente  ' WHEN b.TipoBandoGara = '3' AND isnull(d.LinkedDoc, 0) <> 0 THEN ' EnteProponente RupProponente ' ELSE '' END
    + CASE WHEN dbo.IsTedActive(d.Azienda) = 0 THEN ' RichiestaTED ' ELSE '' END
    + CASE WHEN SIMOG_RCig.EntiAbilitati <> '' AND CHARINDEX(',' + d.Azienda + ',', ',' + SIMOG_RCig.EntiAbilitati + ',') = 0 THEN ' RichiestaCigSimog ' ELSE '' END
    --PER I RILANCI COMPETITIVI SE TROVA IL FLAG, BLOCCA IN TESTATA IL CAMPO "Criterio Formulazione Offerta Economica"
    --+ case when b.TipoProceduraCaratteristica = 'RilancioCompetitivo' and ISNULL(v4.value,'') =  'YES' then ' CriterioFormulazioneOfferte ' else '' end
    AS Not_Editable
  , d.LinkedDoc
  , d.protocollogenerale
  , pda.id AS idpda
  , '' AS StatoProcedura
  , b.DataChiusura
  , d.Azienda AS StazioneAppaltante
  , CASE 
      WHEN d.TipoDoc = 'BANDO_SEMPLIFICATO' THEN b.DataScadenzaOffIndicativa
      WHEN d.TipoDoc = 'BANDO_GARA' THEN b.DataScadenzaOfferta
      ELSE b.DataScadenzaOfferta
    END AS ScadenzaTerminiBando
  , dbo.getclassiIscrizListaAlbi(b.ListaAlbi) AS ClasseIscriz_Bando
  , b.Num_max_lotti_offerti
  , B.RichiediDocumentazione
  , B.Richiesta_terna_subappalto
  , CASE 
      WHEN bs.TipoSceltaContraente = 'ACCORDOQUADRO' THEN 'yes'
      ELSE 'no'
    END AS AQ_RILANCIO_COMPETITVO
  , v3.Value AS BloccaCriteriEreditati
  , b.Controllo_superamento_importo_gara
  , b.TipoSedutaGara
  , b.tiposoglia
  , CASE 
      WHEN SUBSTRING(isnull(L.DZT_ValueDef, ''), 192, 1) = '0'
        THEN 'no' --test del bit 192, il quale indica se sono attivi i parametri seduta virtuale sul cliente
      WHEN b.TipoSedutaGara = 'virtuale'
        THEN 'si'
      WHEN (b.TipoSedutaGara IS NULL OR b.TipoSedutaGara = 'null') AND b.TipoProceduraCaratteristica <> 'RDO'
        THEN 'si'
      WHEN (b.TipoSedutaGara IS NULL OR b.TipoSedutaGara = 'null') AND b.TipoProceduraCaratteristica = 'RDO'
        THEN ''
      ELSE 'no'
    END AS Scelta_Seduta_Virtuale
  , b.RichiestaCigSimog
  , v1_1.Value AS TIPO_SOGGETTO_ART
  , dbo.ISPBMInstalled() AS ISPBMInstalled
  , NULL AS EnteProponente  -- b.EnteProponente
  , NULL AS RupProponente   -- b.RupProponente
  , b.Visualizzazione_Offerta_Tecnica
  , b.InversioneBuste
  --, InversioneBusteRegole
  , b.GestioneQuote
  , b.Accordo_di_Servizio
  , b.Concessione
  , b.AppaltoInEmergenza
  , b.MotivazioneDiEmergenza
  , b.DestinatariNotifica
  , attocp.value AS AllegatoPerOCP
  , b.W9GACAM
  , b.W9SISMA
  , b.W9APOUSCOMP
  , b.W3PROCEDUR
  , b.W3PREINFOR
  , b.W3TERMINE
  , b.DESCRIZIONE_OPZIONI
  , b.RichiestaTED
  , DEST.IdAzi AS Destinatario_Azi
  --campi pnrr/pnc
  , lower(X.ATTIVA_MODULO_PNRR_PNC) AS ATTIVA_MODULO_PNRR_PNC
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
  , case
		  when ',' + diz.DZT_ValueDef + ','  like'%,AFFIDAMENTO_DIRETTO_DUE_FASI,%' then '1'
		  else '0'
	  end AS AFFIDAMENTO_DIRETTO_DUE_FASI
  , case
		  when ',' + diz.DZT_ValueDef + ','  like'%,GROUP_Procedura_RDO,%' then '1'
	    else '0'
    end AS GROUP_Procedura_RDO

FROM CTL_DOC d WITH (NOLOCK)
     INNER JOIN Document_Bando b WITH (NOLOCK) ON d.id = b.idheader
     INNER JOIN profiliutente p WITH (NOLOCK) ON d.idpfu = p.idpfu
     LEFT JOIN marketplace m WITH (NOLOCK) ON m.mpidazimaster = p.pfuidazi
     LEFT OUTER JOIN CTL_DOC_Value v1 WITH (NOLOCK) ON b.idheader = v1.idheader
                                                       AND v1.dzt_name = 'ArtClasMerceologica'
                                                       AND v1.DSE_ID = 'ATTI'
     LEFT OUTER JOIN CTL_DOC_Value v1_1 WITH (NOLOCK) ON b.idheader = v1_1.idheader
                                                         AND v1_1.dzt_name = 'TIPO_SOGGETTO_ART'
                                                         AND v1_1.DSE_ID = 'ATTI'
     LEFT OUTER JOIN CTL_DOC_Value v2 WITH (NOLOCK) ON b.idheader = v2.idheader
                                                       AND v2.dzt_name = 'UserRUP'
                                                       AND v2.DSE_ID = 'InfoTec_comune'
     LEFT JOIN CTL_DOC_Value attocp WITH (NOLOCK) ON attocp.IdHeader = d.id
                                                     AND attocp.DSE_ID = 'PARAMETRI'
                                                     AND attocp.DZT_Name = 'AllegatoPerOCP'
     LEFT OUTER JOIN Document_Bando bs WITH (NOLOCK) ON d.LinkedDoc = bs.idheader
                                                        AND bs.idHeader <> 0
     -- PDA
     LEFT OUTER JOIN CTL_DOC pda WITH (NOLOCK) ON pda.linkeddoc = d.id
                                                  AND pda.deleted = 0
                                                  AND pda.TipoDoc = 'PDA_MICROLOTTI'
     -- REVOCA
     LEFT OUTER JOIN ctl_doc rev WITH (NOLOCK) ON rev.tipodoc = 'REVOCA_BANDO'
                                                  AND rev.deleted = 0
                                                  AND rev.LinkedDoc = d.id
     --BloccaCriteriEreditati
     LEFT OUTER JOIN CTL_DOC_Value v3 WITH (NOLOCK) ON b.idheader = v3.idheader
                                                       AND v3.dzt_name = 'BloccaCriteriEreditati'
                                                       AND v3.DSE_ID = 'InfoTec_comune'
     LEFT OUTER JOIN LIB_Dictionary l WITH (NOLOCK) ON l.DZT_Name = 'SYS_MODULI_RESULT'
     -- RICHIESTA CIG
     LEFT JOIN ctl_doc cig WITH (NOLOCK) ON cig.LinkedDoc = d.Id
                                            AND cig.TipoDoc IN ('RICHIESTA_CIG', 'RICHIESTA_SMART_CIG')
                                            AND cig.Deleted = 0
                                            AND cig.StatoFunzionale <> 'Annullato'
     --ABILITAZIONE SET ENTE PROPONENTE
     LEFT JOIN DM_Attributi DM WITH (NOLOCK) ON DM.lnk = p.pfuIdAzi
                                                AND DM.dztNome = 'SetEnteProponente'
                                                AND vatValore_FT = '1'
     -- recupera le regole da utilizzare per consentire la scelta del campo InversioneBuste
     --cross join ( select  dbo.PARAMETRI('BANDO_GARA_TESTATA','InversioneBusteRegole','DefaultValue','',-1) as InversioneBusteRegole ) as Reg 
     --PER I RILANCI COMPETITIVI SE TROVA IL FLAG, BLOCCA IN TESTATA IL CAMPO "Criterio Formulazione Offerta Economica"
     --left outer join CTL_DOC_Value v4 with(nolock) on b.idheader = v4.idheader and v4.dzt_name = 'CriterioFormulazioneOffertaEconomica' and v3.DSE_ID = 'BLOCCA'
     CROSS JOIN (SELECT dbo.PARAMETRI('GROUP_SIMOG', 'ENTI_ABILITATI', 'DefaultValue', '', - 1) AS EntiAbilitati) AS SIMOG_RCig
     --vado sulla ctl_doc_destinatari per gli affidamenti diretti semplificati
     LEFT OUTER JOIN ctl_Doc_destinatari DEST WITH (NOLOCK) ON DEST.idheader = D.id
                                                               AND b.TipoProceduraCaratteristica = 'AffidamentoSemplificato'
     CROSS JOIN (SELECT dbo.PARAMETRI('ATTIVA_MODULO', 'MODULO_APPALTO_PNRR_PNC', 'ATTIVA', 'NO', - 1) AS ATTIVA_MODULO_PNRR_PNC) AS X
     
     LEFT JOIN lib_dictionary Diz WITH (NOLOCK) ON Diz.DZT_Name='SYS_MODULI_GRUPPI'
GO
