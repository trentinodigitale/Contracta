USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_DOCUMENTI_PUBBLICI_CONVENZIONI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[DASHBOARD_VIEW_DOCUMENTI_PUBBLICI_CONVENZIONI] as
               select
                              Dc.id as idMsg, 
                              'CONVENZIONE' as OPEN_DOC_NAME,

                              CASE WHEN DataFine < GETDATE() or statoconvenzione = 'Chiuso'
            THEN 1
            ELSE 0
                              END AS bScaduto,

                              case when statoconvenzione = 'Chiuso' then 1 else 0 end as bConcluso,
                              1 as EvidenzaPubblica,

                              dc.ProtocolloBando,
                              Protocol as ProtocolloOfferta,
                              cast(DescrizioneEstesa as varchar(8000)) as Oggetto,
                              'Convenzione' as Tipo,
                              '' as Contratto,
                              az1.aziRagioneSociale as DenominazioneEnte,
                              '' as TipoEnte,
                              'NO' as SenzaImporto,
                              dbo.FormatMoney(TotaleOrdinato) as TotaleOrdinato, --a_base_asta, rimosso per rendere coerente il significato del campo
                              '' as di_aggiudicazione,

                              dbo.GETDATEDDMMYYYY (convert(varchar ,c.DataInvio,126))  as DtPubblicazione,
                              dbo.GETDATEDDMMYYYY (convert(varchar ,DataFine,126))  as DtScadenzaBando,
                              convert(varchar(10) ,DataFine,126)  as DtScadenzaBandoTecnical,

                              NULL as DtScadenzaPubblEsito,
                              '' as RequisitiQualificazione,
                              '' as CPV,
                              '' as SCP,
                              '' as URL,
                              NULL as CIG,
                              'NO' as RichiestaQuesito,
                              0 as bEsito,
                              'NO' as VisualizzaQuesiti,
                              '' as Provincia,
                              '' as Comune,
                              '' as aziIndirizzoLeg,

                              numord,
                              dbo.GETDATEDDMMYYYY (convert(varchar ,DataInizio,126))  as DataInizio,
                              az.aziragionesociale as fornitore,
                              StatoConvenzione as statoFunzionale,
                              c.titolo as titoloDocumento,
                              c.titolo,
                              convert( VARCHAR(50) , c.DataInvio, 126) as DtPubblicazioneTecnical,
                              convert(varchar ,DataFine,126)  as DataChiusuraTecnical,
                              '' as TipoProcedura,
                              cast( ISNULL(LM.ML_DESCRIPTION,LV.DMV_DescML) as nvarchar(max) ) as Macro_Convenzione,
                              dbo.FormatMoney(total) as total,
                              dbo.FormatMoney(isnull( DC.Total , 0 ) - isnull( DC.TotaleOrdinato , 0 )) as Residuo_convenzione

                              , c.Fascicolo
                              , case when M.CodFisGest is null then 0 else 1 end as Gestore
                              , c.Protocollo as RegistroSistema
                              , 
                                            case
                                                           when GARA.DataInvio is not null then convert(varchar ,GARA.DataInvio,126) 
                                                           else ''

                                            end as DataPubblicazioneBandoTecnical

                              , isnull(M1.ML_Description, isnull(L1.DMV_DescML,'') ) as DescCategoriaDiSpesa
                              , isnull(M2.ML_Description, L2.DMV_DescML ) as SostenibilitaAmbientale
                              ,  isnull(M3.ML_Description, L3.DMV_DescML ) as SostenibilitaSociale
                              , PossibilitaRinnovo 
                              , dbo.GETDATEDDMMYYYY (convert(varchar ,DataScadenzaOrdinativo,126))  as DataScadenzaOrdinativo
                              , isnull(M4.ML_Description, isnull(L4.DMV_DescML,'') ) as DescAreaMerceologica
                              , DC.Macro_Convenzione as Codice_Macro_Convenzione
                              , isnull(M5.ML_Description, isnull(L5.DMV_DescML,'') ) as DescCategoriaMerceologica
							  , DC.DPCM
               from ctl_doc c   with(nolock)
                                            
                                            left join ProfiliUtente pfu with(nolock) on pfu.IdPfu = c.IdPfu
                                            left join aziende az1 with(nolock) on pfu.pfuidazi=az1.Idazi
                                            inner join Document_Convenzione  DC with(nolock) on DC.id=C.id

                                            left outer join (

                                                           Select sum(Importo) as ImportoAllocabile,LinkedDoc
                                                                          from CTL_DOC with(nolock)
                                                                                                       inner join Document_Convenzione_Quote with(nolock) on id = idheader
                                                                          where StatoDoc = 'Sended' and TipoDoc='QUOTA' 
                                                                          group by (LinkedDoc)

                                            ) as AL2 on AL2.LinkedDoc = DC.id

                                            left outer join Aziende az with(nolock) on dc.AZI_Dest = az.idazi
                                            left outer join LIB_DomainValues LV with(nolock) on LV.DMV_DM_ID='Macro_Convenzione' and DC.Macro_Convenzione=LV.DMV_Cod
                                            left outer join LIB_Multilinguismo LM with(nolock) on LM.ML_KEY=LV.DMV_DescML and LM.ML_LNG='I'

                                            -- VALORIZZIAMO LA COLONNNA BOOLEAN "GESTORE" PER INDICARE CHE LA GARA E' STATA CREATA DA UN ENTE TRA LE AZIENDE CON IL CODICE FISCALE DELL'AZI MASTER ( 1..N )

                                            LEFT JOIN DM_Attributi cfs with(nolock) ON cfs.lnk = az1.IdAzi and cfs.dztNome = 'codicefiscale'

                                            LEFT JOIN (
                                                                                        select distinct cfs.vatValore_FT as CodFisGest
                                                                                                       from marketplace m with(nolock) 
                                                                                                                                     LEFT JOIN DM_Attributi cfs with(nolock) ON cfs.lnk = mpIdAziMaster and cfs.dztNome = 'codicefiscale'
                                                                          ) as M on M.CodFisGest = cfs.vatValore_FT
                              
               
                                            --per recuperare data pubblicazione della gara
                                            --devo matchare anche sul cig dei lotti delle gare
                                            left join ( 
                                                        select  DETT_BANDO.cig as CIG ,  GARA.DataInvio
                                                                        from CTL_DOC  GARA with(nolock ) 
                                                                                        inner join document_bando DETT_BANDO with(nolock) on GARA.id = DETT_BANDO.idheader --and  Divisione_lotti = 0 and isnull(DETT_BANDO.cig,'') <>''--
                                                                        where GARA.tipodoc in ('BANDO_GARA' , 'BANDO_SEMPLIFICATO') 
                                                                                        and GARA.StatoFunzionale <>'inlavorazione' and GARA.deleted=0
                                                                                        and Divisione_lotti = 0 and isnull(DETT_BANDO.cig,'')  <> ''

                                                        union 

                                                        select  DETT_GARA.cig as CIG ,  GARA.DataInvio
                                                                        from CTL_DOC  GARA with(nolock ) 
                                                                                        inner join document_bando DETT_BANDO with(nolock) on GARA.id = DETT_BANDO.idheader --and  Divisione_lotti = 0 and isnull(DETT_BANDO.cig,'') <>''--
                                                                                        inner join document_microlotti_dettagli DETT_GARA with(nolock) on DETT_GARA.idheader = GARA.id and DETT_GARA.tipodoc = GARA.tipodoc and isnull(voce,0)=0 --and isnull(DETT_GARA.cig,'')=DC.CIG_MADRE 
                                                                        where GARA.tipodoc in ('BANDO_GARA' , 'BANDO_SEMPLIFICATO') 
                                                                                        and GARA.StatoFunzionale <>'inlavorazione' and GARA.deleted=0
                                                                                        and Divisione_lotti <> 0 and isnull(DETT_GARA.cig,'') <> ''

													) as GARA on GARA.cig = DC.CIG_MADRE

                                            --left join document_bando DETT_BANDO with(nolock) on Divisione_lotti = 0 and isnull(cig,'') = DC.CIG_MADRE 
                                            --left join document_microlotti_dettagli DETT_GARA with(nolock) on DETT_GARA.tipodoc in ('BANDO_GARA' , 'BANDO_SEMPLIFICATO') and isnull(voce,0)=0 and isnull(DETT_GARA.cig,'')=DC.CIG_MADRE 
                                            --left join ctl_doc GARA with(nolock) on ( GARA.id = DETT_BANDO.idHeader or GARA.id = DETT_GARA.IdHeader ) and GARA.StatoFunzionale <>'inlavorazione' and GARA.deleted=0

                                            --per categoriadispesa
                                            left join CTL_DOC_VALUE C1 with (nolock) on C1.idheader = C.id and C1.dse_id='TESTATA_PRODOTTI' and c1.DZT_Name = 'CategoriaDiSpesa'
                                            left join LIB_DomainValues L1 with (nolock) on L1.DMV_DM_ID='categoriadispesa' and L1.DMV_Cod= C1.value 
                                            left join LIB_Multilinguismo M1 with (nolock) on M1.ML_KEY=L1.DMV_DescML

                                            --per appalto verde
                                            left join CTL_DOC_VALUE C2 with (nolock) on C2.idheader = C.id and C2.dse_id='INFO_AGGIUNTIVE' and C2.DZT_Name = 'Appalto_Verde'
                                            left join LIB_DomainValues L2 with (nolock) on L2.DMV_DM_ID='sino' and L2.DMV_Cod= C2.value 
                                            left join LIB_Multilinguismo M2 with (nolock) on M2.ML_KEY=L2.DMV_DescML

                                            --per acquisto sociale
                                            left join CTL_DOC_VALUE C3 with (nolock) on C3.idheader = C.id and C3.dse_id='INFO_AGGIUNTIVE' and C3.DZT_Name = 'Acquisto_Sociale'
                                            left join LIB_DomainValues L3 with (nolock) on L3.DMV_DM_ID='sino' and L3.DMV_Cod= C3.value 
                                            left join LIB_Multilinguismo M3 with (nolock) on M3.ML_KEY=L3.DMV_DescML

                                            --per area merceologica
                                            left join LIB_DomainValues L4 with (nolock) on L4.DMV_DM_ID='AREA_MERCEOLOGICA' and L4.DMV_Cod= DC.Merceologia 
                                            left join LIB_Multilinguismo M4 with (nolock) on M4.ML_KEY=L4.DMV_DescML

                                            --per CATEGORIE_MERC sulla testata prodotti della convenzione
                                            left join CTL_DOC_VALUE CAT_MERC with (nolock) on CAT_MERC.idheader = C.id and CAT_MERC.dse_id='TESTATA_PRODOTTI' and CAT_MERC.DZT_Name = 'CATEGORIE_MERC'
                                            left join LIB_DomainValues L5 with (nolock) on L5.DMV_DM_ID='CATEGORIE_MERC' and L5.DMV_Cod= isnull(CAT_MERC.value,'')
                                            left join LIB_Multilinguismo M5 with (nolock) on M5.ML_KEY=L5.DMV_DescML

where C.Deleted=0 and DC.Deleted = 0 and C.Tipodoc='CONVENZIONE' and statoconvenzione in ( 'Pubblicato','Chiuso' )
               and ISNULL(DC.EvidenzaPubblica,1)=1  --EVIDENAPUBBLICA A SI
               and  isnull(DC.DataDirittoOblio,'3000-01-01') > GETDATE()
			   and  isnull(C.jumpcheck,'')<>'INTEGRAZIONE'
               ----aggiungo con il kpf 443478 per ovviare ad un duplicato per cig doppio su 2 gare di cui una deleted
               --and ( 
               --                           --trovo il match per il cig ed escludo le gare deleted
               --                           ( 
               --                                         ( DETT_BANDO.idHeader is not null or DETT_GARA.id is not null) and gara.Deleted = 0 
               --                           ) 
               --                           or 
               --                           --non trovo il match per il cig non altero il risultato
               --                           ( DETT_BANDO.idHeader is null and DETT_GARA.id is null)  
               --            ) 
               
--            and DC.Macro_Convenzione = 'Dispositivi MEdici'
GO
