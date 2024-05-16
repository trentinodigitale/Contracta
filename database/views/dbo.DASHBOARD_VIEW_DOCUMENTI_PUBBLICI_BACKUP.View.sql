USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_DOCUMENTI_PUBBLICI_BACKUP]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Versione=4&data=2013-07-02&Attivita=42115&Nominativo=Marco
CREATE VIEW [dbo].[DASHBOARD_VIEW_DOCUMENTI_PUBBLICI_BACKUP] AS
SELECT a.* 
---*** ATTENZIONE ***---
-- Il dato va gestito aggiungendo l'informazione della sede sul Bando
      , azi.aziProvinciaLeg AS Provincia 
      , azi.aziLocalitaLeg AS Comune 
      , CASE a.tipoappalto 
             WHEN '15496' THEN 'Via S. Maria La Nova, 43'
             ELSE azi.aziIndirizzoLeg
        END AS Indirizzo 
  FROM (
                -----------------------------------------------------------------------------------------
                -- estrazione dei bandi dalla tabella dei messaggi ( Documento generico ) per Bandi / Inviti
                -----------------------------------------------------------------------------------------
                SELECT 
                        -- attributi di servizio
                       f.IdMsg 
                     , f.IdDoc
                     , f.iType
                     , f.iSubType
                     , f.iType + ';' + f.iSubType AS OPEN_DOC_NAME
                     , f.IdMittente
                     , f.TipoAppalto
                     , CASE WHEN f.ExpiryDate < CONVERT(VARCHAR(50), GETDATE(), 126) 
                                THEN 1 
                                ELSE 0 
                       END AS bScaduto
                     , CASE WHEN DataPubbEsito IS NOT NULL AND esito.DtScadenzaPubblEsito < GETDATE()  
                                THEN 1
                                ELSE 0
                        END AS bConcluso 
                      , '1' as EvidenzaPubblica
                      , ISNULL(cag.DMV_COD, '')  AS CriterioAggiudicazioneGara
                      , f.ProtocolloBando
                      , f.TipoProcedura
                      , Stato AS StatoGD 
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
                      , CASE f.tipoappalto 
                             WHEN '15495' THEN 'Forniture'
                             WHEN '15496' THEN 'Lavori'
                             WHEN '15494' THEN 'Servizi'
                        END AS Contratto 
                      , f.RagSoc AS DenominazioneEnte 

                ---*** ATTENZIONE ***---
                -- Il dato va gestito aggiungendo il campo alla tabella Aziende
                                        --TipoEnte
                                        --a.TipoDiAmministr AS TipoEnte ,
                      , 'Province' AS TipoEnte 

                      , CASE WHEN f.iSubType IN (25, 37, 64) 
                                THEN 'NO'
                        END AS SenzaImporto 
                      , dbo.FormatMoney(ImportoBaseAsta) AS a_base_asta

                ---*** ATTENZIONE ***---
                -- Il dato va gestito aggiungendo l'informazione alla pubblicazione dell'esito
                --                        di_aggiudicazione
                      , dbo.FormatMoney(esito.ValoreContratto) AS di_aggiudicazione
                      , dbo.GETDATEDDMMYYYY(f.ReceivedDataMsg) AS DtPubblicazione
                      , dbo.GETDATEDDMMYYYY(f.ExpiryDate) AS DtScadenzaBando 
                      , f.ExpiryDate AS DtScadenzaBandoTecnical 
                      , esito.DtScadenzaPubblEsitoDMY AS DtScadenzaPubblEsito

                ---*** ATTENZIONE ***---
                -- il dato non  al momento disponibile e necessita di implementazione
                      , '' AS RequisitiQualificazione

                ---*** ATTENZIONE ***---
                -- il dato non  al momento disponibile e necessita di implementazione 
                      , '' AS CPV

                ---*** ATTENZIONE ***---
                -- il dato non  al momento disponibile e necessita di implementazione futura
                -- forse prevedendo una integrazione con il sistema di pubblicazione https://www.serviziocontrattipubblici.it/
                      , '' AS SCP

                ---*** ATTENZIONE ***---
                -- il dato non  al momento disponibile e necessita di implementazione futura
                -- forse prevedendo una integrazione con il sistema di pubblicazione https://www.serviziocontrattipubblici.it/
                      , '' AS URL
                      , f.CIG
                      , 'NO' AS  RichiestaQuesito 
                      , CASE WHEN ID_MSG_BANDO IS NULL 
                                THEN 0 
                                ELSE 1 
                        END AS bEsito
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
                                      , CONVERT(VARCHAR(10), DATEADD(day, 180, DataPubbEsito), 103)  AS DtScadenzaPubblEsitoDMY
                                   FROM DOCUMENT_RISULTATODIGARA e
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
                                       , CONVERT(VARCHAR(10), DataPubbEsito, 103) AS DataPubbEsito
                                       , ValoreContratto 
                                       , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                                       , CONVERT(VARCHAR(10), DATEADD(day, 180, DataPubbEsito), 103)  AS DtScadenzaPubblEsitoDMY
                                    FROM DOCUMENT_RISULTATODIGARA e
                                 ) AS esito ON umIdMsg = ID_MSG_BANDO

                WHERE um.umStato = 0 
                  AND um.umIdPfu = -10
                  --AND um.umInput = 0
                  AND iSubType IN (25, 37, 64)
                        
        /* Aste */

        UNION ALL -- mdt 

                SELECT f.IdMsg 
                     , f.IdDoc
                     , f.iType
                     , f.iSubType
                     , f.iType + ';' + f.iSubType AS OPEN_DOC_NAME
                     , f.IdMittente
                     , f.TipoAppalto
                     , CASE WHEN f.DataFineAsta < CONVERT(VARCHAR(50), GETDATE(), 126) 
                            THEN 1 
                            ELSE 0
                       END AS bScaduto
                     , CASE WHEN DataPubbEsito IS NOT NULL AND esito.DtScadenzaPubblEsito < GETDATE()  
                                THEN 1
                                ELSE 0
                        END AS bConcluso 
                      , '1' as EvidenzaPubblica
                      , ISNULL(cag.DMV_COD, '')  AS CriterioAggiudicazioneGara
                      , f.ProtocolloBando
                      , f.TipoProcedura
                      , Stato AS StatoGD
                      , CASE NumProduct_BANDO_rettifiche
                                WHEN '' THEN Object_Cover1
                                WHEN '0' THEN Object_Cover1
                                ELSE '<strong>Bando Rettificato - </strong> ' + Object_Cover1
                        END + '&nbsp;' AS Oggetto
                      , 'Bando' AS Tipo 
                      , CASE f.tipoappalto 
                                WHEN '15495' THEN 'Forniture'
                                WHEN '15496' THEN 'Lavori'
                                WHEN '15494' THEN 'Servizi'
                        END AS Contratto 
                      , f.RagSoc AS DenominazioneEnte 
                      , 'Province' AS TipoEnte 
                      , 'NO' AS SenzaImporto 
                      , dbo.FormatMoney(ImportoAppalto) AS a_base_asta
                      , dbo.FormatMoney(esito.ValoreContratto) AS di_aggiudicazione
                      , dbo.GETDATEDDMMYYYY(f.ReceivedDataMsg) AS DtPubblicazione
                      , dbo.GETDATEDDMMYYYY(f.DataFineAsta) AS DtScadenzaBando 
                      , f.DataFineAsta AS DtScadenzaBandoTecnical 
                      , esito.DtScadenzaPubblEsitoDMY AS DtScadenzaPubblEsito
                      , '' AS RequisitiQualificazione
                      , '' AS CPV
                      , '' AS SCP
                      , '' AS URL
                      , f.CIG
                      , 'NO' AS RichiestaQuesito 
                      , CASE WHEN ID_MSG_BANDO IS NULL 
                                THEN 0 
                                ELSE 1 
                        END AS bEsito
                      , 'NO' AS VisualizzaQuesiti
                   FROM TAB_MESSAGGI_FIELDS f WITH(NOLOCK) 
                  INNER JOIN TAB_UTENTI_MESSAGGI um WITH(NOLOCK) ON um.umIdMsg = f.idmsg
                   LEFT OUTER JOIN LIB_DomainValues cag ON cag.DMV_CodExt = CriterioAggiudicazioneGara AND cag.DMV_DM_ID = 'Criterio' 
                   LEFT OUTER JOIN (SELECT ID_MSG_BANDO
                                         , CONVERT(VARCHAR(10), DataPubbEsito, 103) AS DataPubbEsito
                                         , ValoreContratto 
                                         , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                                         , CONVERT(VARCHAR(10), DATEADD(day, 180, DataPubbEsito), 103)  AS DtScadenzaPubblEsitoDMY
                                      FROM DOCUMENT_RISULTATODIGARA e
                                    ) AS esito ON umIdMsg = ID_MSG_BANDO
                  WHERE um.umStato = 0 
                    AND um.umInput = CAST(0 AS BIT)
                    AND iSubType IN (78, 112, 152)
                    AND Stato = '2' 
                    AND AuctionState <> '3'
                    AND REPLACE(f.DataFineAsta, 'T', ' ') > DATEADD(year, - 1, GETDATE()) 

        UNION ALL /* Procedure IN Economia 55;48 */
        
                SELECT f.IdMsg 
                     , f.IdDoc
                     , f.iType
                     , f.iSubType
                     , f.iType + ';' + f.iSubType AS OPEN_DOC_NAME
                     , f.IdMittente
                     , f.TipoAppalto
                     , CASE WHEN f.ExpiryDate < CONVERT(VARCHAR(50), GETDATE(), 126) 
                            THEN 1 
                            ELSE 0 
                        END AS bScaduto
                     , CASE WHEN DataPubbEsito IS NOT NULL AND esito.DtScadenzaPubblEsito < GETDATE()  
                                THEN 1
                                ELSE 0
                       END AS bConcluso 
                     , '1' as EvidenzaPubblica
                     , ISNULL(cag.DMV_COD, '')  AS CriterioAggiudicazioneGara
                     , f.ProtocolloBando
                     , f.TipoProcedura
                     , Stato AS StatoGD
                     , CASE NumProduct_BANDO_rettifiche
                                WHEN '' THEN Object_Cover1
                                WHEN '0' THEN Object_Cover1
                                ELSE '<strong>Bando Rettificato - </strong> ' + Object_Cover1
                       END + '&nbsp;' AS Oggetto
                     , 'Bando' AS Tipo 
                     , CASE f.tipoappalto 
                                WHEN '15495' THEN 'Forniture'
                                WHEN '15496' THEN 'Lavori'
                                WHEN '15494' THEN 'Servizi'
                       END AS Contratto 
                     , f.RagSoc AS DenominazioneEnte 
                     , 'Province' AS TipoEnte 
                     , 'NO' AS SenzaImporto 
                     , dbo.FormatMoney(ImportoBaseAsta) AS a_base_asta
                     , dbo.FormatMoney(esito.ValoreContratto) AS di_aggiudicazione
                     , dbo.GETDATEDDMMYYYY(f.ReceivedDataMsg) AS DtPubblicazione
                     , dbo.GETDATEDDMMYYYY (f.ExpiryDate) AS DtScadenzaBando 
                     , f.ExpiryDate AS DtScadenzaBandoTecnical 
                     , esito.DtScadenzaPubblEsitoDMY AS DtScadenzaPubblEsito
                     , '' AS RequisitiQualificazione
                     , '' AS CPV
                     , '' AS SCP
                     , '' AS URL
                     , f.CIG
                     , 'NO' AS RichiestaQuesito 
                     , CASE WHEN ID_MSG_BANDO IS NULL 
                               THEN 0 
                               ELSE 1 
                       END AS bEsito
                     , 'NO' AS VisualizzaQuesiti
                  FROM TAB_MESSAGGI_FIELDS f WITH(NOLOCK)
                 INNER JOIN TAB_UTENTI_MESSAGGI um WITH(NOLOCK) ON um.umIdMsg  = f.idmsg
                  LEFT OUTER JOIN LIB_DomainValues cag ON cag.DMV_CodExt = CriterioAggiudicazioneGara AND cag.DMV_DM_ID = 'Criterio' 
                  LEFT OUTER JOIN (SELECT ID_MSG_BANDO
                                        , CONVERT(VARCHAR(10), DataPubbEsito, 103) AS DataPubbEsito
                                        , ValoreContratto 
                                        , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                                        , CONVERT(VARCHAR(10), DATEADD(day, 180, DataPubbEsito), 103)  AS DtScadenzaPubblEsitoDMY
                                     FROM DOCUMENT_RISULTATODIGARA e
                                  ) AS esito ON umIdMsg = ID_MSG_BANDO
                  WHERE um.umStato = 0 
                    AND um.umInput = CAST(0 AS BIT)
                    AND iSubType = 48
                    AND Stato = '2'
                    AND REPLACE(ExpiryDate, 'T', ' ') > DATEADD(year, - 1, GETDATE()) 

        UNION ALL
                -----------------------------------------------------------------------------------------
                -- estrazione dei bandi dalla tabella dei messaggi ( Documento generico ) 55;180
                -----------------------------------------------------------------------------------------
                SELECT f.IdMsg 
                     , f.IdDoc
                     , f.iType
                     , f.iSubType
                     , f.iType + ';' + f.iSubType AS OPEN_DOC_NAME
                     , f.IdMittente
                     , f.TipoAppalto
                     , CASE WHEN f.ExpiryDate < CONVERT(VARCHAR(50), GETDATE(), 126) 
                                THEN 1 
                                ELSE 0 
                       END AS bScaduto
                     , CASE WHEN DataPubbEsito IS NOT NULL AND esito.DtScadenzaPubblEsito < GETDATE()  
                                THEN 1
                                ELSE 0
                       END AS bConcluso 
                     , '1' as EvidenzaPubblica
                     , ISNULL(cag.DMV_COD, '')  AS CriterioAggiudicazioneGara
                     , f.ProtocolloBando
                     , f.TipoProcedura
                     , Stato AS StatoGD
                     , CASE NumProduct_BANDO_rettifiche
                                WHEN '' THEN Object_Cover1
                                WHEN '0' THEN Object_Cover1
                                ELSE '<strong>Bando Rettificato - </strong> ' + Object_Cover1
                       END + '&nbsp;' AS Oggetto
                     , 'Bando' AS Tipo 
                     , CASE f.tipoappalto 
                                WHEN '15495' THEN 'Forniture'
                                WHEN '15496' THEN 'Lavori'
                                WHEN '15494' THEN 'Servizi'
                       END AS Contratto 
                     , f.RagSoc AS DenominazioneEnte 
                     , 'Province' AS TipoEnte
                     , 'NO' AS SenzaImporto 
                     , dbo.FormatMoney(ImportoBaseAsta) AS a_base_asta 
                     , dbo.FormatMoney(esito.ValoreContratto) AS di_aggiudicazione
                     , dbo.GETDATEDDMMYYYY(f.ReceivedDataMsg) AS DtPubblicazione
                     , dbo.GETDATEDDMMYYYY (f.ExpiryDate) AS DtScadenzaBando 
                     , f.ExpiryDate AS DtScadenzaBandoTecnical 
                     , esito.DtScadenzaPubblEsitoDMY AS DtScadenzaPubblEsito
                     , '' AS RequisitiQualificazione
                     , '' AS CPV
                     , '' AS SCP
                     , '' AS URL
                     , f.CIG
                     , 'YES' AS  RichiestaQuesito 
                     , CASE WHEN ID_MSG_BANDO IS NULL 
                               THEN 0 
                               ELSE 1 
                       END AS bEsito
                     , 'YES' AS VisualizzaQuesiti
                FROM TAB_MESSAGGI_FIELDS f WITH(NOLOCK) 
               INNER JOIN TAB_UTENTI_MESSAGGI um WITH(NOLOCK) ON um.umIdMsg  = f.idmsg
               LEFT OUTER JOIN LIB_DomainValues cag ON cag.DMV_CodExt = CriterioAggiudicazioneGara AND cag.DMV_DM_ID = 'Criterio' 
                       LEFT OUTER JOIN (SELECT mfOUT.mfIdMsg AS ID_MSG_BANDO
                                              , CONVERT(VARCHAR(10), DataPubbEsito, 103) AS DataPubbEsito
                                              , ValoreContratto 
                                              , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                                              , CONVERT(VARCHAR(10), DATEADD(day, 180, DataPubbEsito), 103)  AS DtScadenzaPubblEsitoDMY
                                           FROM DOCUMENT_RISULTATODIGARA e
                                          INNER JOIN MessageFields mfIN WITH(NOLOCK) ON e.ID_MSG_BANDO = mfIN.mfIdMsg
                                          INNER JOIN MessageFields mfOUT WITH(NOLOCK) ON mfOUT.mfFieldValue = mfIN.mfFieldValue AND mfOUT.mfIType = mfIN.mfIType 
                                                AND mfOUT.mfFieldName = mfIN.mfFieldName
                                                AND mfOUT.mfFieldName = 'IdDoc' 
                                          INNER JOIN TAB_UTENTI_MESSAGGI WITH(NOLOCK) ON mfOUT.mfIdMsg = umIdMsg 
                                                AND umStato = 0 
                                                AND umInput = CAST(0 AS BIT)
                                          WHERE mfOUT.mfISubType <> mfIN.mfISubType
                           ) AS esito ON umIdMsg = ID_MSG_BANDO

               WHERE UM.umStato = 0
                 AND UM.umInput = CAST(0 AS BIT)
                 --AND UM.umIdPfu = -10
                 AND iSubType = 179
                 AND AdvancedState <> '6'
                 AND Stato = '2'

UNION ALL
                -----------------------------------------------------------------------------------------
                -- estrazione dei bandi dalla tabella dei messaggi ( Documento generico ) 55;168
                -----------------------------------------------------------------------------------------
                SELECT f.IdMsg 
                     , f.IdDoc
                     , f.iType
                     , f.iSubType
                     , f.iType + ';' + f.iSubType AS OPEN_DOC_NAME
                     , f.IdMittente
                     , f.TipoAppalto
                     , CASE WHEN f.ExpiryDate < CONVERT(VARCHAR(50), GETDATE(), 126) 
                                THEN 1 
                                ELSE 0 
                       END AS bScaduto
                     , CASE WHEN esito.DtScadenzaPubblEsito < GETDATE()  
                                THEN 1
                                ELSE 0
                       END AS bConcluso 
                     , CASE WHEN f.EvidenzaPubblica = ''
                                THEN '1'
                                ELSE f.EvidenzaPubblica
                       END AS EvidenzaPubblica
                     , ISNULL(cag.DMV_COD, '')  AS CriterioAggiudicazioneGara
                     , f.ProtocolloBando
                     , f.TipoProcedura
                     , Stato AS StatoGD
                     , CASE NumProduct_BANDO_rettifiche
                                WHEN '' THEN Object_Cover1
                                WHEN '0' THEN Object_Cover1
                                ELSE '<strong>Bando Rettificato - </strong> ' + Object_Cover1
                       END + '&nbsp;' AS Oggetto
                     , 'Bando' AS Tipo 
                     , CASE f.tipoappalto 
                                WHEN '15495' THEN 'Forniture'
                                WHEN '15496' THEN 'Lavori'
                                WHEN '15494' THEN 'Servizi'
                       END AS Contratto 
                     , f.RagSoc AS DenominazioneEnte 
                     , 'Province' AS TipoEnte 
                     , 'NO' SenzaImporto 
                     , dbo.FormatMoney(ImportoBaseAsta) AS a_base_asta
                     , dbo.FormatMoney(esito.ValoreContratto) AS di_aggiudicazione
                     , dbo.GETDATEDDMMYYYY (f.ReceivedDataMsg) AS DtPubblicazione
                     , dbo.GETDATEDDMMYYYY (f.ExpiryDate) AS DtScadenzaBando 
                     , f.ExpiryDate AS DtScadenzaBandoTecnical 
                     , esito.DtScadenzaPubblEsitoDMY AS DtScadenzaPubblEsito
                     , '' AS RequisitiQualificazione
                     , '' AS CPV
                     , '' AS SCP
                     , '' AS URL
                     , f.CIG
                     , CASE WHEN RichiestaQuesito  <> '1' 
                                THEN 'NO'
			   ELSE CASE WHEN TermineRichiestaQuesiti <> '' AND REPLACE(TermineRichiestaQuesiti, 'T', ' ') > GETDATE()
			                   THEN 'YES'
			             ELSE CASE WHEN TermineRichiestaQuesiti = '' AND REPLACE(f.ExpiryDate, 'T', ' ') > GETDATE()
			                       THEN 'YES'
			                       ELSE 'NO'
			                  END
			        END  
		       END AS RichiestaQuesito
                     
      --               , CASE RichiestaQuesito 
						--WHEN '1' THEN 'YES' 
						--ELSE 'NO'  
					 --  END AS RichiestaQuesito

                     , CASE WHEN ID_MSG_BANDO IS NULL 
                               THEN 0 
                               ELSE 1 
                       END AS bEsito
                     , 'SI' AS VisualizzaQuesiti
                  FROM TAB_MESSAGGI_FIELDS f WITH(NOLOCK)
                 --INNER JOIN FolderDocuments ON fdIdMsg = IdMsg
                 INNER JOIN TAB_UTENTI_MESSAGGI um WITH(NOLOCK) ON um.umIdMsg  = f.idmsg
                 LEFT OUTER JOIN LIB_DomainValues cag ON cag.DMV_CodExt = CriterioAggiudicazioneGara AND cag.DMV_DM_ID = 'Criterio' 
            LEFT OUTER JOIN ( SELECT mfOUT.mfIdMsg AS ID_MSG_BANDO
                                  , CONVERT(VARCHAR(10), DataPubbEsito, 103) AS DataPubbEsito
                                  , ValoreContratto 
                                  , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                                  , CONVERT(VARCHAR(10), DATEADD(day, 180, DataPubbEsito), 103)  AS DtScadenzaPubblEsitoDMY
                               FROM DOCUMENT_RISULTATODIGARA e
                              INNER JOIN MessageFields mfIN WITH(NOLOCK) ON e.ID_MSG_BANDO = mfIN.mfIdMsg
                              INNER JOIN MessageFields mfOUT WITH(NOLOCK) ON mfOUT.mfFieldValue = mfIN.mfFieldValue AND mfOUT.mfIType = mfIN.mfIType 
                                    AND mfOUT.mfFieldName = mfIN.mfFieldName
                                    AND mfOUT.mfFieldName = 'IdDoc' 
                              INNER JOIN TAB_UTENTI_MESSAGGI WITH(NOLOCK) ON mfOUT.mfIdMsg = umIdMsg 
                                    AND umStato = 0 
                                    AND umInput = CAST(0 AS BIT)
                              WHERE mfOUT.mfISubType <> mfIN.mfISubType
                           
                             ) AS esito ON umIdMsg = ID_MSG_BANDO

                 WHERE 
				   UM.umStato = 0
                   AND UM.umInput = 0
                   AND AdvancedState <> '6'
                   AND IdDoc NOT IN (SELECT JumpCheck FROM CTL_DOC WHERE TipoDoc = 'BANDO_NON_VIS' AND Deleted=0)
				   AND isnull(EvidenzaPubblica,'1')	='1'
				   --AND ( ( UM.umIdPfu = -10 AND iSubType = 168 ) OR ( UM.umIdPfu > 0 AND iSubType = 167 AND f.TipoBando='3' AND F.Stato='2' ) )
				   AND iSubType = 167 
				   AND F.Stato='2'
UNION ALL
            -----------------------------------------------------------------------------------------
            -- estrazione dei bandi dalla tabella dei messaggi ( Documento generico ) per Esiti
            -----------------------------------------------------------------------------------------
            SELECT f.IdMsg 
                 , f.IdDoc
                 , f.iType
                 , f.iSubType
                 , f.iType + ';' + f.iSubType AS OPEN_DOC_NAME
                 , f.IdMittente
                 , f.TipoAppalto
                 , 0 AS bScaduto
                 , CASE WHEN esito.DtScadenzaPubblEsito < GETDATE()  
                        THEN 1
                        ELSE 0
                    END AS bConcluso 
                 , '1' AS EvidenzaPubblica
                 , ISNULL(cag.DMV_COD, '')  AS CriterioAggiudicazioneGara
                 , f.ProtocolloBando
                 , f.TipoProcedura
                 , Stato AS StatoGD
                 , CASE NumProduct_BANDO_rettifiche
                        WHEN '' THEN Object_Cover1
                        WHEN '0' THEN Object_Cover1
                        ELSE '<strong>Bando Rettificato - </strong> ' + Object_Cover1
                   END + '&nbsp;' AS Oggetto
                 , 'Esito' AS Tipo 
                 , CASE f.tipoappalto 
                        WHEN '15495' THEN 'Forniture'
                        WHEN '15496' THEN 'Lavori'
                        WHEN '15494' THEN 'Servizi'
                   END AS Contratto 
                 , f.RagSoc AS DenominazioneEnte 
                 , 'Province' AS TipoEnte 
                 , 'NO' AS SenzaImporto 
                 , CASE WHEN f.iSubType in (78, 112, 152) 
                                THEN dbo.FormatMoney(ImportoAppalto)
                        ELSE dbo.FormatMoney(ImportoBaseAsta) 
                   END AS a_base_asta
                 , dbo.FormatMoney(esito.ValoreContratto) AS di_aggiudicazione
                 --, dbo.GetDateDDMMYYYY(CONVERT(VARCHAR(30), DATEADD(day, 180, esito.DataPubbEsito), 121)) AS DtPubblicazione
                 , CONVERT(VARCHAR(30), esito.DataPubbEsito, 103) AS DtPubblicazione
                 , dbo.GetDateDDMMYYYY (CASE f.iSubType   
                                               WHEN '78' THEN f.DataFineAsta
                                               WHEN '112' THEN f.DataFineAsta
                                               WHEN '152' THEN f.DataFineAsta
                                               ELSE f.ExpiryDate
                                         END  
                                        ) AS DtScadenzaBando 

                  , CASE f.iSubType   
                            WHEN '78' THEN f.DataFineAsta
                            WHEN '112' THEN f.DataFineAsta
                            WHEN '152' THEN f.DataFineAsta
                            ELSE f.ExpiryDate
                    END AS DtScadenzaBandoTecnical 
                  , esito.DtScadenzaPubblEsitoDMY AS DtScadenzaPubblEsito
                  , '' AS RequisitiQualificazione
                  , '' AS CPV
                  , esito.CodSCP AS SCP
                  , esito.UrlSCP AS URL
                  , f.CIG
                  , 'NO' AS RichiestaQuesito 
                  , CASE WHEN ID_MSG_BANDO IS NULL 
                              THEN 0 
                              ELSE 1 
                    END AS bEsito
                  , 'NO' AS VisualizzaQuesiti
            FROM TAB_MESSAGGI_FIELDS f WITH(NOLOCK)
           INNER JOIN TAB_UTENTI_MESSAGGI um WITH(NOLOCK) ON um.umIdMsg  = f.idmsg
           LEFT OUTER JOIN LIB_DomainValues cag ON cag.DMV_CodExt = CriterioAggiudicazioneGara AND cag.DMV_DM_ID = 'Criterio' 
           INNER JOIN (SELECT ID_MSG_BANDO
                            , CONVERT(VARCHAR(10), DataPubbEsito, 103) AS DataPubbEsito
                            , ValoreContratto 
                            , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                            , CONVERT(VARCHAR(10), DATEADD(day, 180, DataPubbEsito), 103)  AS DtScadenzaPubblEsitoDMY
                            , CodSCP
                            , UrlSCP
                         FROM DOCUMENT_RISULTATODIGARA e
                       ) AS esito ON umIdMsg = ID_MSG_BANDO
           WHERE umStato = 0
             AND umInput = CAST(0 AS BIT)
             AND f.iSubType NOT IN (25, 37, 64, 179)

UNION ALL-- mdt
            -----------------------------------------------------------------------------------------
            -- estrazione dei bandi dalla tabella dei messaggi ( Documento generico ) per Esiti
            -----------------------------------------------------------------------------------------
            SELECT f.IdMsg 
                 , f.IdDoc
                 , f.iType
                 , f.iSubType
                 , f.iType + ';' + f.iSubType AS OPEN_DOC_NAME
                 , f.IdMittente
                 , f.TipoAppalto
                 , 0 AS bScaduto
                 , CASE WHEN esito.DtScadenzaPubblEsito < GETDATE()  
                        THEN 1
                        ELSE 0
                    END AS bConcluso 
                 , '1' AS EvidenzaPubblica
                 , ISNULL(cag.DMV_COD, '')  AS CriterioAggiudicazioneGara
                 , f.ProtocolloBando
                 , f.TipoProcedura
                 , Stato AS StatoGD
                 , CASE NumProduct_BANDO_rettifiche
                        WHEN '' THEN Object_Cover1
                        WHEN '0' THEN Object_Cover1
                        ELSE '<strong>Bando Rettificato - </strong> ' + Object_Cover1
                   END + '&nbsp;' AS Oggetto
                 , 'Esito' AS Tipo 
                 , CASE f.tipoappalto 
                        WHEN '15495' THEN 'Forniture'
                        WHEN '15496' THEN 'Lavori'
                        WHEN '15494' THEN 'Servizi'
                   END AS Contratto 
                 , f.RagSoc AS DenominazioneEnte 
                 , 'Province' AS TipoEnte 
                 , 'NO' AS SenzaImporto 
                 , CASE WHEN f.iSubType in (78, 112, 152) 
                                THEN dbo.FormatMoney(ImportoAppalto)
                        ELSE dbo.FormatMoney(ImportoBaseAsta) 
                   END AS a_base_asta
                 , dbo.FormatMoney(esito.ValoreContratto) AS di_aggiudicazione
                 --, dbo.GetDateDDMMYYYY(CONVERT(VARCHAR(30), DATEADD(day, 180, esito.DataPubbEsito), 121)) AS DtPubblicazione
                 , CONVERT(VARCHAR(30), esito.DataPubbEsito, 103) AS DtPubblicazione
                 , dbo.GetDateDDMMYYYY (CASE f.iSubType   
                                               WHEN '78' THEN f.DataFineAsta
                                               WHEN '112' THEN f.DataFineAsta
                                               WHEN '152' THEN f.DataFineAsta
                                               ELSE f.ExpiryDate
                                         END  
                                        ) AS DtScadenzaBando 

                  , CASE f.iSubType   
                            WHEN '78' THEN f.DataFineAsta
                            WHEN '112' THEN f.DataFineAsta
                            WHEN '152' THEN f.DataFineAsta
                            ELSE f.ExpiryDate
                    END AS DtScadenzaBandoTecnical 
                  , esito.DtScadenzaPubblEsitoDMY AS DtScadenzaPubblEsito
                  , '' AS RequisitiQualificazione
                  , '' AS CPV
                  , esito.CodSCP AS SCP
                  , esito.UrlSCP AS URL
                  , f.CIG
                  , 'NO' AS RichiestaQuesito 
                  , CASE WHEN ID_MSG_BANDO IS NULL 
                              THEN 0 
                              ELSE 1 
                    END AS bEsito
                  , 'NO' AS VisualizzaQuesiti
            FROM TAB_MESSAGGI_FIELDS f WITH(NOLOCK)
           INNER JOIN TAB_UTENTI_MESSAGGI um WITH(NOLOCK) ON um.umIdMsg  = f.idmsg
           LEFT OUTER JOIN LIB_DomainValues cag ON cag.DMV_CodExt = CriterioAggiudicazioneGara AND cag.DMV_DM_ID = 'Criterio' 
           INNER JOIN (SELECT mfOUT.mfIdMsg AS ID_MSG_BANDO
                                              , CONVERT(VARCHAR(10)
                                              , DataPubbEsito, 103) AS DataPubbEsito
                                              , ValoreContratto
                                              , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                                              , CONVERT(VARCHAR(10), DATEADD(day, 180, DataPubbEsito), 103)  AS DtScadenzaPubblEsitoDMY
                                              , CodSCP
                                              , UrlSCP
                                           FROM DOCUMENT_RISULTATODIGARA e
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
                                               , CONVERT(VARCHAR(10), DataPubbEsito, 103) AS DataPubbEsito
                                               , ValoreContratto 
                                               , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                                               , CONVERT(VARCHAR(10), DATEADD(day, 180, DataPubbEsito), 103)  AS DtScadenzaPubblEsitoDMY
                                               , CodSCP
                                               , UrlSCP
                                            FROM DOCUMENT_RISULTATODIGARA e
                       ) AS esito ON umIdMsg = ID_MSG_BANDO
           WHERE umStato = 0
             AND umInput = CAST(0 AS BIT)
             AND f.iSubType IN (25, 37, 64, 179)


) AS a 
  INNER JOIN ProfiliUtente p ON a.IdMittente = p.IdPfu
  INNER JOIN Aziende azi ON azi.IdAzi = p.pfuIdAzi

WHERE a.ProtocolloBando NOT LIKE 'Demo%'
  AND a.IdMsg NOT IN (223, 36059,27802,31474,30868,43812, 45232,57573, 70061)




GO
