USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ULTIMI_DOCUMENTI_PUBBLICI_ORIGINAL]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[DASHBOARD_VIEW_ULTIMI_DOCUMENTI_PUBBLICI_ORIGINAL] AS 
SELECT TOP 20 a.* 
  FROM (
  
                -----------------------------------------------------------------------------------------
                -- estrazione dei bandi dalla tabella dei messaggi ( Documento generico ) per Bandi / Inviti
                -----------------------------------------------------------------------------------------
                SELECT 
                        -- attributi di servizio
                       f.IdMsg 
                     , f.iType + ';' + f.iSubType AS OPEN_DOC_NAME
                     , f.ProtocolloBando
                      , CASE NumProduct_BANDO_rettifiche
                                WHEN '' THEN Object_Cover1
                                WHEN '0' THEN Object_Cover1
                                ELSE '<strong>Bando Rettificato - </strong> ' + Object_Cover1
                        END + '&nbsp;' AS Oggetto
                        -- attributi DPCM 26/04/2011 Tab. A 
                      , CASE WHEN f.iSubType IN (25, 37) 
                                THEN 'Bando'
                             WHEN f.iSubType = 64
                                THEN 'Avviso'
                             ELSE 'Altro'
                        END AS Tipo 
                      , dbo.GETDATEDDMMYYYY(f.ReceivedDataMsg) AS DtPubblicazione
                      , dbo.GETDATEDDMMYYYY(f.ExpiryDate) AS DtScadenzaBando 
                      , f.ExpiryDate AS DtScadenzaBandoTecnical 
                      , 'NO' AS  RichiestaQuesito 
                      , CASE WHEN f.iSubType IN (25, 37) 
                                THEN 'YES'
                                ELSE 'NO'
                        END AS VisualizzaQuesiti
                FROM TAB_MESSAGGI_FIELDS f WITH(NOLOCK) 
                INNER JOIN TAB_UTENTI_MESSAGGI um WITH(NOLOCK) ON um.umIdMsg = f.idmsg
                LEFT OUTER JOIN LIB_DomainValues cag ON cag.DMV_CodExt = CriterioAggiudicazioneGara AND cag.DMV_DM_ID = 'Criterio' 
                LEFT OUTER JOIN (SELECT mfOUT.mfIdMsg AS ID_MSG_BANDO
                                      , CONVERT(VARCHAR(10)
                                      , DataPubbEsito, 103) AS DataPubbEsito
                                      , ValoreContratto 
                                      , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                                   FROM DOCUMENT_RISULTATODIGARA e
                                  INNER JOIN MessageFields mfIN WITH(NOLOCK) ON e.ID_MSG_BANDO = mfIN.mfIdMsg
                                  INNER JOIN MessageFields mfOUT WITH(NOLOCK) ON mfOUT.mfFieldValue = mfIN.mfFieldValue AND mfOUT.mfIType = mfIN.mfIType 
                                        AND mfOUT.mfFieldName = mfIN.mfFieldName
                                        AND mfOUT.mfFieldName = 'IdDoc' 
                                  INNER JOIN TAB_UTENTI_MESSAGGI WITH(NOLOCK) ON mfOUT.mfIdMsg = umIdMsg 
                                        AND umStato = 0 
                                        AND umInput = 0
                                  WHERE mfOUT.mfISubType <> mfIN.mfISubType
                                  UNION
                                  SELECT ID_MSG_BANDO
                                       , CONVERT(VARCHAR(10), DataPubbEsito, 103) AS DataPubbEsito
                                       , ValoreContratto 
                                       , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                                    FROM DOCUMENT_RISULTATODIGARA e
                                 ) AS esito ON IdMsg = ID_MSG_BANDO

                WHERE um.umStato = 0 
                  AND um.umIdPfu = -10
                  AND um.umInput = 0
                  AND iSubType IN (25, 37, 64)
				  AND ( isnull(EvidenzaPubblica,'1') ='1' OR isnull(EvidenzaPubblica,'1') ='' )
                        
        /* Aste */

        UNION -- mdt 

                SELECT f.IdMsg 
                     , f.iType + ';' + f.iSubType AS OPEN_DOC_NAME
                      , f.ProtocolloBando
                      , CASE NumProduct_BANDO_rettifiche
                                WHEN '' THEN Object_Cover1
                                WHEN '0' THEN Object_Cover1
                                ELSE '<strong>Bando Rettificato - </strong> ' + Object_Cover1
                        END + '&nbsp;' AS Oggetto
                      , 'Bando' AS Tipo 
                      , dbo.GETDATEDDMMYYYY(f.ReceivedDataMsg) AS DtPubblicazione
                      , dbo.GETDATEDDMMYYYY(f.DataFineAsta) AS DtScadenzaBando 
                      , f.DataFineAsta AS DtScadenzaBandoTecnical 
                      , 'NO' AS RichiestaQuesito 
                      , 'NO' AS VisualizzaQuesiti
                   FROM TAB_MESSAGGI_FIELDS f WITH(NOLOCK) 
                  INNER JOIN TAB_UTENTI_MESSAGGI um WITH(NOLOCK) ON um.umIdMsg = f.idmsg
                  LEFT OUTER JOIN LIB_DomainValues cag ON cag.DMV_CodExt = CriterioAggiudicazioneGara AND cag.DMV_DM_ID = 'Criterio' 
                   LEFT OUTER JOIN (SELECT ID_MSG_BANDO
                                         , CONVERT(VARCHAR(10), DataPubbEsito, 103) AS DataPubbEsito
                                         , ValoreContratto 
                                         , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                                      FROM DOCUMENT_RISULTATODIGARA e
                                    ) AS esito ON IdMsg = ID_MSG_BANDO
                  WHERE um.umStato = 0 
                    AND um.umInput = 0
                    AND iSubType IN (78, 112, 152)
                    AND Stato = '2' 
                    AND AuctionState <> '3'
                    AND REPLACE(f.DataFineAsta, 'T', ' ') > DATEADD(year, - 1, GETDATE()) 
					AND ( isnull(EvidenzaPubblica,'1') ='1' OR isnull(EvidenzaPubblica,'1') ='' )

        UNION /* Procedure IN Economia 55;48 */
        
                SELECT f.IdMsg 
                     , f.iType + ';' + f.iSubType AS OPEN_DOC_NAME
                     , f.ProtocolloBando
                     , CASE NumProduct_BANDO_rettifiche
                                WHEN '' THEN Object_Cover1
                                WHEN '0' THEN Object_Cover1
                                ELSE '<strong>Bando Rettificato - </strong> ' + Object_Cover1
                       END + '&nbsp;' AS Oggetto
                     , 'Bando' AS Tipo 
                     , dbo.GETDATEDDMMYYYY(f.ReceivedDataMsg) AS DtPubblicazione
                     , dbo.GETDATEDDMMYYYY (f.ExpiryDate) AS DtScadenzaBando 
                     , f.ExpiryDate AS DtScadenzaBandoTecnical 
                     , 'NO' AS RichiestaQuesito 
                     , 'NO' AS VisualizzaQuesiti
                  FROM TAB_MESSAGGI_FIELDS f WITH(NOLOCK)
                 INNER JOIN TAB_UTENTI_MESSAGGI um WITH(NOLOCK) ON um.umIdMsg  = f.idmsg
                 LEFT OUTER JOIN LIB_DomainValues cag ON cag.DMV_CodExt = CriterioAggiudicazioneGara AND cag.DMV_DM_ID = 'Criterio' 
                  LEFT OUTER JOIN (SELECT ID_MSG_BANDO
                                        , CONVERT(VARCHAR(10), DataPubbEsito, 103) AS DataPubbEsito
                                        , ValoreContratto 
                                        , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                                     FROM DOCUMENT_RISULTATODIGARA e
                                  ) AS esito ON IdMsg = ID_MSG_BANDO
                  WHERE um.umStato = 0 
                    AND um.umInput = 0
                    AND iSubType = 48
                    AND Stato = '2'
                    AND REPLACE(ExpiryDate, 'T', ' ') > DATEADD(year, - 1, GETDATE()) 
					AND ( isnull(EvidenzaPubblica,'1') ='1' OR isnull(EvidenzaPubblica,'1') ='' )

        UNION
                -----------------------------------------------------------------------------------------
                -- estrazione dei bandi dalla tabella dei messaggi ( Documento generico ) 55;180
                -----------------------------------------------------------------------------------------
                SELECT f.IdMsg 
                     , f.iType + ';' + f.iSubType AS OPEN_DOC_NAME
                     , f.ProtocolloBando
                     , CASE NumProduct_BANDO_rettifiche
                                WHEN '' THEN Object_Cover1
                                WHEN '0' THEN Object_Cover1
                                ELSE '<strong>Bando Rettificato - </strong> ' + Object_Cover1
                       END + '&nbsp;' AS Oggetto
                     , 'Bando' AS Tipo 
                     , dbo.GETDATEDDMMYYYY(f.ReceivedDataMsg) AS DtPubblicazione
                     , dbo.GETDATEDDMMYYYY (f.ExpiryDate) AS DtScadenzaBando 
                     , f.ExpiryDate AS DtScadenzaBandoTecnical 
                     , 'YES' AS  RichiestaQuesito 
                     , 'YES' AS VisualizzaQuesiti
                FROM TAB_MESSAGGI_FIELDS f WITH(NOLOCK) 
               INNER JOIN TAB_UTENTI_MESSAGGI um WITH(NOLOCK) ON um.umIdMsg  = f.idmsg
               LEFT OUTER JOIN LIB_DomainValues cag ON cag.DMV_CodExt = CriterioAggiudicazioneGara AND cag.DMV_DM_ID = 'Criterio' 
                       LEFT OUTER JOIN (SELECT mfOUT.mfIdMsg AS ID_MSG_BANDO
                                              , CONVERT(VARCHAR(10), DataPubbEsito, 103) AS DataPubbEsito
                                              , ValoreContratto 
                                              , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                                           FROM DOCUMENT_RISULTATODIGARA e
                                          INNER JOIN MessageFields mfIN WITH(NOLOCK) ON e.ID_MSG_BANDO = mfIN.mfIdMsg
                                          INNER JOIN MessageFields mfOUT WITH(NOLOCK) ON mfOUT.mfFieldValue = mfIN.mfFieldValue AND mfOUT.mfIType = mfIN.mfIType 
                                                AND mfOUT.mfFieldName = mfIN.mfFieldName
                                                AND mfOUT.mfFieldName = 'IdDoc' 
                                          INNER JOIN TAB_UTENTI_MESSAGGI WITH(NOLOCK) ON mfOUT.mfIdMsg = umIdMsg 
                                                AND umStato = 0 
                                                AND umInput = 0
                                          WHERE mfOUT.mfISubType <> mfIN.mfISubType
                           ) AS esito ON IdMsg = ID_MSG_BANDO

               WHERE UM.umStato = 0
                 AND UM.umInput = 0
                 --AND UM.umIdPfu = -10
                 AND iSubType IN (179)
                 AND AdvancedState <> '6'
                 AND Stato = '2'
				 AND ( isnull(EvidenzaPubblica,'1') ='1' OR isnull(EvidenzaPubblica,'1') ='' )

UNION
                -----------------------------------------------------------------------------------------
                -- estrazione dei bandi dalla tabella dei messaggi ( Documento generico ) 55;168
                -----------------------------------------------------------------------------------------
                SELECT f.IdMsg 
                     , f.iType + ';' + f.iSubType AS OPEN_DOC_NAME
                     , f.ProtocolloBando
                     , CASE NumProduct_BANDO_rettifiche
                                WHEN '' THEN Object_Cover1
                                WHEN '0' THEN Object_Cover1
                                ELSE '<strong>Bando Rettificato - </strong> ' + Object_Cover1
                       END + '&nbsp;' AS Oggetto
                     , 'Bando' AS Tipo 
                     , dbo.GETDATEDDMMYYYY (f.ReceivedDataMsg) AS DtPubblicazione
                     , dbo.GETDATEDDMMYYYY (f.ExpiryDate) AS DtScadenzaBando 
                     , f.ExpiryDate AS DtScadenzaBandoTecnical 
                     ,  CASE WHEN RichiestaQuesito  <> '1' OR ( tipobando = 3 AND ProceduraGara = 15478 ) 
                                THEN 'NO'
					    ELSE CASE WHEN TermineRichiestaQuesiti <> '' AND REPLACE(TermineRichiestaQuesiti, 'T', ' ') > GETDATE()
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

                  FROM TAB_MESSAGGI_FIELDS f WITH(NOLOCK)
                 --INNER JOIN FolderDocuments ON fdIdMsg = IdMsg
                 INNER JOIN TAB_UTENTI_MESSAGGI um WITH(NOLOCK) ON um.umIdMsg  = f.idmsg
                 LEFT OUTER JOIN LIB_DomainValues cag ON cag.DMV_CodExt = CriterioAggiudicazioneGara AND cag.DMV_DM_ID = 'Criterio' 
            LEFT OUTER JOIN ( SELECT ID_MSG_BANDO
                                   , CONVERT(VARCHAR(10), DataPubbEsito, 103) AS DataPubbEsito
                                   , ValoreContratto 
                                   , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                                FROM DOCUMENT_RISULTATODIGARA e
                             ) AS esito ON IdMsg = ID_MSG_BANDO
                 WHERE UM.umStato = 0
                   AND UM.umInput = 0
                   --AND AdvancedState <> '6'
                   AND IdDoc NOT IN (SELECT JumpCheck FROM CTL_DOC WHERE TipoDoc = 'BANDO_NON_VIS' AND Deleted=0)
				   
				   AND ( isnull(EvidenzaPubblica,'1') ='1' OR isnull(EvidenzaPubblica,'1') ='' )

				   --AND ( ( UM.umIdPfu = -10 AND iSubType = 168 ) OR ( UM.umIdPfu > 0 AND iSubType = 167 AND f.TipoBando='3' AND F.Stato='2' ) )
				   AND iSubType = 167 
				   AND F.Stato='2'

union  -- si aggiungono i bandi semplificati

	
		select 
			ctl_doc.id as IdMsg, 
			'BANDO_SEMPLIFICATO' as OPEN_DOC_NAME,
			ProtocolloBando,
			cast( Body as nvarchar(4000)) as Oggetto, 

			'Bando' as Tipo, 

			dbo.GETDATEDDMMYYYY (convert( VARCHAR(50) , DataInvio, 126)) as DtPubblicazione, 

			dbo.GETDATEDDMMYYYY (convert( VARCHAR(50) , isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa), 126)) AS DtScadenzaBando ,
			convert( VARCHAR(50) , isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa), 126) AS DtScadenzaBandoTecnical ,
			'NO' AS RichiestaQuesito
			, 'SI' AS VisualizzaQuesiti
		from ctl_doc with(nolock) 
			inner join aziende a with(nolock) on azienda = a.idazi
			inner join document_bando  with(nolock)  on id = idheader

			left outer join (
				select distinct id , ID_MSG_BANDO, DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito from Document_RisultatoDiGara with(nolock)	
					inner join DOCUMENT_RISULTATODIGARA_ROW with(nolock) on id = idheader 
					) as r on r.ID_MSG_BANDO = -CTL_DOC.id

				
			-- inner join per recuperare la descrizione della colonna 'Contratto' corrispondente a tipoAppaltoGara
			inner join (
					select dmv_descml, dmv_cod from 
						lib_domainvalues where dmv_dm_id = 'Tipologia'
				 ) as domVal on domVal.dmv_cod = Document_Bando.TipoAppaltoGara

		where tipodoc = 'BANDO_SEMPLIFICATO' and statofunzionale not in ('InLavorazione','InApprove','Annullato','Rifiutato','NEW_SEMPLIFICATO') and deleted = 0

UNION ALL   --- AGGIUNGO BANDO_GARA


		SELECT 
			ctl_doc.id as IdMsg, 
			TipoDoc as OPEN_DOC_NAME,
			ProtocolloBando,

			case StatoFunzionale
				when 'Revocato' then '<strong>Bando Revocato - </strong> ' + cast( Body as nvarchar(4000)) 
				when 'InRettifica' then '<strong>Bando in Rettifica - </strong> ' + cast( Body as nvarchar(4000)) 
				else
					case when isnull(v.linkeddoc,0) > 0 or isnull(Z.linkeddoc,0) > 0
						 then '<strong>Bando Rettificato - </strong> ' + cast( Body as nvarchar(4000)) 
					else
						cast( Body as nvarchar(4000)) 
					end
			end as Oggetto, 

			'Bando' as Tipo, 
			dbo.GETDATEDDMMYYYY (convert( VARCHAR(50) , DataInvio, 126)) as DtPubblicazione, 
			dbo.GETDATEDDMMYYYY (convert( VARCHAR(50) , isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa), 126)) AS DtScadenzaBando ,
			convert( VARCHAR(50) , isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa), 126) AS DtScadenzaBandoTecnical ,

			CASE WHEN richiestaquesito = 1
				THEN 'YES'
				ELSE 'NO'
			END AS RichiestaQuesito

			, 'SI' AS VisualizzaQuesiti

		FROM ctl_doc with(nolock) 
			INNER JOIN aziende a with(nolock) on azienda = a.idazi
			INNER JOIN document_bando  with(nolock)  on id = idheader

			LEFT OUTER JOIN (
				select distinct id , ID_MSG_BANDO, DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito from Document_RisultatoDiGara with(nolock)	
					inner join DOCUMENT_RISULTATODIGARA_ROW with(nolock) on id = idheader 
					) as r on r.ID_MSG_BANDO = -CTL_DOC.id

				
			-- inner join per recuperare la descrizione della colonna 'Contratto' corrispondente a tipoAppaltoGara
			INNER JOIN (
					SELECT dmv_descml, dmv_cod from 
						lib_domainvalues  with(nolock) where dmv_dm_id = 'Tipologia'
				 ) as domVal on domVal.dmv_cod = Document_Bando.TipoAppaltoGara


			-- Se è presente la StrutturaAziendale ed è avvalorata recupero la descrizione dell'ente espletante da li altrimenti 
			-- da dall'azienda presente nel campo 'azienda' del documento
			--LEFT OUTER JOIN (
			--					SELECT DISTINCT 
			--						Descrizione AS DMV_DescML,
			--						CAST(IdAz AS varchar) + '#' + Path AS DMV_Cod
			--					FROM AZ_STRUTTURA  with(nolock)
			--				 ) AS viewTipoAmmin1 ON viewTipoAmmin1.dmv_cod = ctl_doc.StrutturaAziendale

			LEFT OUTER JOIN (
							  SELECT dmv_descml, dmv_cod FROM
								lib_domainvalues  with(nolock) WHERE dmv_dm_id = 'TipoDiAmministr'
							) AS viewTipoAmmin2 ON viewTipoAmmin2.dmv_cod = a.TipoDiAmministr
			left  join (Select distinct(linkedDoc) from ctl_doc where tipodoc='PROROGA_GARA' and statofunzionale = 'Inviato' and deleted = 0 ) V on V.LinkedDoc=CTL_DOC.id
			left  join (Select distinct(linkedDoc) from ctl_doc where tipodoc='RETTIFICA_GARA' and statofunzionale = 'Inviato' and deleted = 0) Z on Z.LinkedDoc=CTL_DOC.id

		WHERE tipodoc = 'BANDO_GARA' and statofunzionale not in ('InLavorazione','InApprove','Annullato','Rifiutato') and deleted = 0 and evidenzapubblica = '1'



) AS a 
WHERE a.ProtocolloBando NOT LIKE 'Demo%'
  AND a.IdMsg NOT IN (223, 36059,27802,31474,30868,43812, 45232,57573, 70061)
ORDER BY a.DtScadenzaBandoTecnical DESC




GO
