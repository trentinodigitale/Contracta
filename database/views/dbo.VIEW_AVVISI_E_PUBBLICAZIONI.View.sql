USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_AVVISI_E_PUBBLICAZIONI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW_AVVISI_E_PUBBLICAZIONI] as

	select	
				case when c.LinkedDoc < 0 then c.LinkedDoc*-1 else c.LinkedDoc end as idGara,
				isnull(gara.tipodoc,'') as tipoDocGara,

				case when c.tipodoc = 'AVVISO_GARA' then 'AVVISO' else 'PUBBLICAZIONE' end as tipo,

				cast ( case when c.tipodoc = 'AVVISO_GARA' then c.Note else CV.value end as nvarchar(max)) as note

				, case when c.tipodoc = 'AVVISO_GARA' then c.SIGN_ATTACH else CV2.value end as allegato
				, dbo.GETDATEDDMMYYYY ( convert( VARCHAR(50) , c.DataInvio , 126)) AS DtPubblicazione
				, comp.pfuNome as compilatore

				, isnull(CV3.value,'') as TipoDocumentoEsito
				, convert( VARCHAR(50) , c.DataInvio , 126) AS DtPubblicazioneTecnical

				, isnull(f.ProtocolloBando, gara.protocollo) as ProtocolloBando
				, isnull(f.RagSoc, azi.aziRagioneSociale) AS DenominazioneEnte
				
				, case when f.idmsg is null then
				                convert( VARCHAR(50) , isnull( dtGara.DataScadenzaOfferta ,dtGara.DataScadenzaOffIndicativa), 126) 
				       else f.ExpiryDate end AS DtScadenzaBandoTecnical
				       
				,  case when f.idmsg is null then gara.TipoDoc 
				        else f.iType + ';' + f.iSubType
				        end
				   AS OPEN_DOC_NAME

				, case when f.idmsg is null then 
				                 CASE WHEN dtGara.richiestaquesito = 1
						          THEN 'YES'
					              ELSE 'NO'
				                 END
				        else
				                CASE WHEN f.RichiestaQuesito  <> '1' OR ( f.tipobando = 3 AND f.ProceduraGara = 15478 ) 
                                                        THEN 'NO'
						                        ELSE	CASE WHEN f.TermineRichiestaQuesiti <> '' AND REPLACE(f.TermineRichiestaQuesiti, 'T', ' ') > GETDATE()
										                         THEN 'YES'
									                          ELSE CASE WHEN f.TermineRichiestaQuesiti = '' AND REPLACE(f.ExpiryDate, 'T', ' ') > GETDATE()
												                          THEN 'YES'
											                            ELSE 'NO'
											                        END
								                        END  
				                         END	
				          end			              
				                  AS RichiestaQuesito

				 , case when f.idmsg is null then
				                CASE WHEN TIPOBANDOGARA <> '3' THEN 'SI' ELSE 'NO' END 
				        else 
				                CASE f.TipoBando
                                                        WHEN '3' THEN 'NO'
                                                        ELSE 'SI'
                                                 END
                                          end 
				        AS VisualizzaQuesiti

				 , isnull(f.idmsg, gara.id) as IdMsg

			from ctl_doc c with(nolock)
					left join profiliutente comp with(nolock) ON c.idpfu = comp.idpfu
					left join ctl_doc gara with(nolock) ON gara.id = c.LinkedDoc -- per le nuove gare
					left join document_bando dtGara with(nolock)  on dtGara.idheader = gara.id
					left join aziende azi with(nolock) on gara.azienda = azi.idazi

					left join CTL_DOC_Value CV with(nolock) on  CV.IdHeader=C.id and CV.DSE_ID='TESTATA' and CV.DZT_Name='Precisazione'
					left join CTL_DOC_Value CV2 with(nolock) on  CV2.IdHeader=C.id and CV2.DSE_ID='TESTATA' and CV2.DZT_Name='DocumentoAllegato'
					left join CTL_DOC_Value CV3 with(nolock) on  CV3.IdHeader=C.id and CV3.DSE_ID='TESTATA' and CV3.DZT_Name='TipoDocumentoEsito'
					left join DOCUMENT_RISULTATODIGARA D with(nolock) on -C.LinkedDoc=ID_MSG_BANDO
					Left join Document_RisultatoDiGara_Row DR with(nolock) on D.id=DR.idHeader and C.Protocollo=DR.Protocollo 

					-- per le vecchie gare
					left join TAB_MESSAGGI_FIELDS f WITH(NOLOCK) ON f.idmsg = -C.LinkedDoc

			where c.tipodoc in ( 'AVVISO_GARA', 'NEW_RISULTATODIGARA') and c.deleted = 0 and c.statofunzionale in ( 'Inviato' )

	union 
	
		-- UNION PER I VECCHI RISULTATI DI GARA

		SELECT  
				f.IdMsg as idGara
				, '' as tipoDocGara
				, 'PUBBLICAZIONE' as tipo
				, esito.precisazione as note
				, '' as allegato
				, DtScadenzaPubblEsitoDMY AS DtPubblicazione
				, '' as compilatore
				, 'Esito' as TipoDocumentoEsito
				, esito.DtPubblicazioneTecnical

				, f.ProtocolloBando
				, f.RagSoc AS DenominazioneEnte 
				, f.ExpiryDate AS DtScadenzaBandoTecnical 
				, f.iType + ';' + f.iSubType AS OPEN_DOC_NAME

				,  CASE WHEN RichiestaQuesito  <> '1' OR ( tipobando = 3 AND ProceduraGara = 15478 ) 
                                THEN 'NO'
						ELSE	CASE WHEN TermineRichiestaQuesiti <> '' AND REPLACE(TermineRichiestaQuesiti, 'T', ' ') > GETDATE()
										 THEN 'YES'
									  ELSE CASE WHEN TermineRichiestaQuesiti = '' AND REPLACE(f.ExpiryDate, 'T', ' ') > GETDATE()
												  THEN 'YES'
											    ELSE 'NO'
											END
								END  
				 END AS RichiestaQuesito

				 , CASE TipoBando
                                WHEN '3' THEN 'NO'
                                ELSE 'SI'
                       END AS VisualizzaQuesiti

				, IdMsg


		FROM TAB_MESSAGGI_FIELDS f WITH(NOLOCK)
			   INNER JOIN TAB_UTENTI_MESSAGGI um WITH(NOLOCK) ON um.umIdMsg  = f.idmsg
			   LEFT OUTER JOIN LIB_DomainValues cag with(nolock) ON cag.DMV_CodExt = CriterioAggiudicazioneGara AND cag.DMV_DM_ID = 'Criterio' 
			   INNER JOIN (			SELECT mfOUT.mfIdMsg AS ID_MSG_BANDO
												  , DataPubbEsito
												  , ValoreContratto
												  , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
												  , CONVERT(VARCHAR(10), DATEADD(day, 180, DataPubbEsito), 103)  AS DtScadenzaPubblEsitoDMY
												  , convert( VARCHAR(50) , DataPubbEsito , 126) AS DtPubblicazioneTecnical
												  , CodSCP
												  , UrlSCP
										 , e.datacreazione
										 , isnull(e.Precisazione, e.oggetto) as precisazione
									  FROM DOCUMENT_RISULTATODIGARA e with(nolock)
											  INNER JOIN TAB_MESSAGGI_FIELDS with(nolock) ON e.ID_MSG_BANDO = IdMsg AND RTRIM(LTRIM(AdvancedState)) IN ('', '0')
											  INNER JOIN MessageFields mfIN WITH(NOLOCK) ON e.ID_MSG_BANDO = mfIN.mfIdMsg
											  INNER JOIN MessageFields mfOUT WITH(NOLOCK) ON mfOUT.mfFieldValue = mfIN.mfFieldValue AND mfOUT.mfIType = mfIN.mfIType 
													AND mfOUT.mfFieldName = mfIN.mfFieldName 
													AND mfOUT.mfFieldName = 'IdDoc' 
											  INNER JOIN TAB_UTENTI_MESSAGGI WITH(NOLOCK) ON mfOUT.mfIdMsg = umIdMsg 
													AND umStato = 0 
													AND umInput = CAST(0 AS BIT)
									  WHERE mfOUT.mfISubType <> mfIN.mfISubType

							 UNION ALL

									SELECT ID_MSG_BANDO
										, DataPubbEsito
										, ValoreContratto 
										, DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
										, CONVERT(VARCHAR(10), DATEADD(day, 180, DataPubbEsito), 103)  AS DtScadenzaPubblEsitoDMY
										, convert( VARCHAR(50) , DataPubbEsito , 126) AS DtPubblicazioneTecnical
										, CodSCP
										, UrlSCP
										, e.datacreazione
										, isnull(e.Precisazione, e.oggetto) as precisazione
									FROM DOCUMENT_RISULTATODIGARA e with(nolock)

						   ) AS esito ON umIdMsg = ID_MSG_BANDO
			   WHERE umStato = 0
				 AND umInput = CAST(0 AS BIT)
				 AND f.iSubType IN (25, 37, 64, 179, 167)



GO
