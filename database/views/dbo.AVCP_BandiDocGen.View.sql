USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AVCP_BandiDocGen]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Versione=1&data=2014-01-14&Attivita=51444&Nominativo=Leone
CREATE VIEW [dbo].[AVCP_BandiDocGen] AS
SELECT a.*, dm.vatValore_FT as CFenteProponente, azi.aziRagioneSociale as DenominazioneEnteProponente, azi.idazi as AziendaMittente, NULL  as DataInizio, NULL  as DataFine

  FROM (
        -----------------------------------------------------------------------------------------
        -- estrazione dei bandi aperti vecchio tipo
        -----------------------------------------------------------------------------------------
        SELECT 

                f.IdMsg
                , f.IdDoc
                , f.iType
                , f.iSubType
                , f.IdMittente
                , f.TipoAppalto
                , ISNULL(cag.DMV_COD, '')  AS CriterioAggiudicazioneGara
                , f.ProtocolloBando
				, f.Protocol as CigAusiliare
                , 'APERTA' as TipoProcedura
				, Object_Cover1	 AS Oggetto
                , dbo.FormatMoney(ImportoBaseAsta) AS a_base_asta
                , dbo.FormatMoney(esito.ValoreContratto) AS di_aggiudicazione
                , convert ( datetime, case when ISDATE(f.ReceivedDataMsg) = 1 then f.ReceivedDataMsg else null end , 126) AS DtPubblicazione
                , dbo.GETDATEDDMMYYYY (f.ExpiryDate ) AS DtScadenzaBando 
				--, convert ( datetime, f.ExpiryDate , 126 ) AS DtScadenzaBandoTecnical 
				, '' AS DtScadenzaBandoTecnical 
                , esito.DtScadenzaPubblEsitoDMY AS DtScadenzaPubblEsito
                , f.CIG
				, '2' as TipoBando
				,'0' AS divisioneInLotti

				, cast(f.iType as varchar(10)) + ';' + cast(f.iSubType as varchar(10))  as TipoDoc
				, f.proceduraGara as CodTipoProcedura

        FROM TAB_MESSAGGI_FIELDS f WITH(NOLOCK) 

                INNER JOIN TAB_UTENTI_MESSAGGI um WITH(NOLOCK) ON um.umIdMsg = f.idmsg
                LEFT OUTER JOIN LIB_DomainValues cag WITH(NOLOCK) ON cag.DMV_CodExt = CriterioAggiudicazioneGara AND cag.DMV_DM_ID = 'Criterio' 
                LEFT OUTER JOIN (SELECT mfOUT.mfIdMsg AS ID_MSG_BANDO
                                      , CONVERT(VARCHAR(10)
                                      , DataPubbEsito, 103) AS DataPubbEsito
                                      , ValoreContratto 
                                      , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                                      , CONVERT(VARCHAR(10), DATEADD(day, 180, DataPubbEsito), 103)  AS DtScadenzaPubblEsitoDMY
                                   FROM DOCUMENT_RISULTATODIGARA e WITH(NOLOCK) 
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
                                    FROM DOCUMENT_RISULTATODIGARA e WITH(NOLOCK) 
                                 ) AS esito ON umIdMsg = ID_MSG_BANDO

                WHERE um.umStato = 0 
                  AND um.umIdPfu = -10
                  AND iSubType = '25'

        /* Aste */

		

        UNION ALL -- mdt 

                SELECT f.IdMsg 
                     , f.IdDoc
                     , f.iType
                     , f.iSubType
                     , f.IdMittente
                     , f.TipoAppalto
                      , ISNULL(cag.DMV_COD, '')  AS CriterioAggiudicazioneGara
                      , f.ProtocolloBando
					  , f.Protocol as CigAusiliare
                      , 'INVITO' as TipoProcedura
					  , Object_Cover1 AS Oggetto
                      , dbo.FormatMoney(ImportoAppalto) AS a_base_asta
                      , dbo.FormatMoney(esito.ValoreContratto) AS di_aggiudicazione
					  , convert ( datetime, case when ISDATE(f.ReceivedDataMsg) = 1 then f.ReceivedDataMsg else null end, 126) AS DtPubblicazione
                      , dbo.GETDATEDDMMYYYY (f.DataFineAsta) AS DtScadenzaBando 
					  --, convert ( datetime, f.DataFineAsta , 126 ) AS DtScadenzaBandoTecnical 
					  , '' AS DtScadenzaBandoTecnical 
	                  , esito.DtScadenzaPubblEsitoDMY AS DtScadenzaPubblEsito
                      , f.CIG
					  , '3' as TipoBando

					  ,'0' AS divisioneInLotti

					  , cast(f.iType as varchar(10)) + ';' + cast(f.iSubType as varchar(10))  as TipoDoc
					  , f.proceduraGara as CodTipoProcedura

                   FROM TAB_MESSAGGI_FIELDS f WITH(NOLOCK) 
                  INNER JOIN TAB_UTENTI_MESSAGGI um WITH(NOLOCK) ON um.umIdMsg = f.idmsg
                   LEFT OUTER JOIN LIB_DomainValues cag WITH(NOLOCK)  ON cag.DMV_CodExt = CriterioAggiudicazioneGara AND cag.DMV_DM_ID = 'Criterio' 
                   LEFT OUTER JOIN (SELECT ID_MSG_BANDO
                                         , CONVERT(VARCHAR(10), DataPubbEsito, 103) AS DataPubbEsito
                                         , ValoreContratto 
                                         , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                                         , CONVERT(VARCHAR(10), DATEADD(day, 180, DataPubbEsito), 103)  AS DtScadenzaPubblEsitoDMY
                                      FROM DOCUMENT_RISULTATODIGARA e WITH(NOLOCK) 
                                    ) AS esito ON umIdMsg = ID_MSG_BANDO
                  WHERE um.umStato = 0 
                    AND um.umInput = CAST(0 AS BIT)
                    AND iSubType IN ('78', '112', '152')
                    AND Stato = '2' 
                    AND AuctionState <> '3'
                    --AND REPLACE(f.DataFineAsta, 'T', ' ') > DATEADD(year, - 1, GETDATE()) 

        UNION ALL /* Procedure IN Economia 55;48 */
        
                SELECT f.IdMsg 
                     , f.IdDoc
                     , f.iType
                     , f.iSubType
                     , f.IdMittente
                     , f.TipoAppalto
                     , ISNULL(cag.DMV_COD, '')  AS CriterioAggiudicazioneGara
                     , f.ProtocolloBando
					 , f.Protocol as CigAusiliare
                     , 'INVITO' as TipoProcedura
					 , Object_Cover1  AS Oggetto
                     , dbo.FormatMoney(ImportoBaseAsta) AS a_base_asta
                     , dbo.FormatMoney(esito.ValoreContratto) AS di_aggiudicazione
					 , convert ( datetime, case when ISDATE(f.ReceivedDataMsg) = 1 then f.ReceivedDataMsg else null end, 126) AS DtPubblicazione
                     , dbo.GETDATEDDMMYYYY (f.ExpiryDate) AS DtScadenzaBando 
					 -- , convert ( datetime, LEFT(f.ExpiryDate, 19) , 126 ) AS DtScadenzaBandoTecnical 
					 , '' AS DtScadenzaBandoTecnical 
                     , esito.DtScadenzaPubblEsitoDMY AS DtScadenzaPubblEsito
                     , f.CIG
					 , '3' as TipoBando
					 ,'0' AS divisioneInLotti

					 , cast(f.iType as varchar(10)) + ';' + cast(f.iSubType as varchar(10))  as TipoDoc
					 , case when iSubType = 68 then '15479'
						    else f.proceduraGara 
					   end as CodTipoProcedura

                  FROM TAB_MESSAGGI_FIELDS f WITH(NOLOCK)
                 INNER JOIN TAB_UTENTI_MESSAGGI um WITH(NOLOCK) ON um.umIdMsg  = f.idmsg
                  LEFT OUTER JOIN LIB_DomainValues cag WITH(NOLOCK)  ON cag.DMV_CodExt = CriterioAggiudicazioneGara AND cag.DMV_DM_ID = 'Criterio' 
                  LEFT OUTER JOIN (SELECT ID_MSG_BANDO
                                        , CONVERT(VARCHAR(10), DataPubbEsito, 103) AS DataPubbEsito
                                        , ValoreContratto 
                                        , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                                        , CONVERT(VARCHAR(10), DATEADD(day, 180, DataPubbEsito), 103)  AS DtScadenzaPubblEsitoDMY
                                     FROM DOCUMENT_RISULTATODIGARA e WITH(NOLOCK) 
                                  ) AS esito ON umIdMsg = ID_MSG_BANDO
                  WHERE um.umStato = 0 
                    AND um.umInput = CAST(0 AS BIT)
                    AND iSubType IN ('48', '68', '20')
                    AND Stato = '2'


        UNION ALL

                -----------------------------------------------------------------------------------------
                -- estrazione dei bandi dalla tabella dei messaggi ( Documento generico ) 55;180
                -----------------------------------------------------------------------------------------
                SELECT f.IdMsg 
                     , f.IdDoc
                     , f.iType
                     , f.iSubType
                     , f.IdMittente
                     , f.TipoAppalto
                     , ISNULL(cag.DMV_COD, '')  AS CriterioAggiudicazioneGara
                     , f.ProtocolloBando
					 , f.Protocol as CigAusiliare
                     , f.TipoProcedura
					 , Object_Cover1 AS Oggetto
                     , dbo.FormatMoney(ImportoBaseAsta) AS a_base_asta 
                     , dbo.FormatMoney(esito.ValoreContratto) AS di_aggiudicazione
					 , convert ( datetime, case when ISDATE(f.ReceivedDataMsg) = 1 then f.ReceivedDataMsg else null end, 126) AS DtPubblicazione
                     , dbo.GETDATEDDMMYYYY (f.ExpiryDate) AS DtScadenzaBando 
					 -- , convert ( datetime, f.ExpiryDate , 126 ) AS DtScadenzaBandoTecnical 
					 ,'' as DtScadenzaBandoTecnical 
                     , esito.DtScadenzaPubblEsitoDMY AS DtScadenzaPubblEsito
                     , f.CIG
					 , '2' as TipoBando
					 , '0' AS divisioneInLotti
					 , cast(f.iType as varchar(10)) + ';' + cast(f.iSubType as varchar(10))  as TipoDoc
					 , f.proceduraGara as CodTipoProcedura

                FROM TAB_MESSAGGI_FIELDS f WITH(NOLOCK) 
               INNER JOIN TAB_UTENTI_MESSAGGI um WITH(NOLOCK) ON um.umIdMsg  = f.idmsg
               LEFT OUTER JOIN LIB_DomainValues cag ON cag.DMV_CodExt = CriterioAggiudicazioneGara AND cag.DMV_DM_ID = 'Criterio' 
                       LEFT OUTER JOIN (SELECT mfOUT.mfIdMsg AS ID_MSG_BANDO
                                              , CONVERT(VARCHAR(10), DataPubbEsito, 103) AS DataPubbEsito
                                              , ValoreContratto 
                                              , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                                              , CONVERT(VARCHAR(10), DATEADD(day, 180, DataPubbEsito), 103)  AS DtScadenzaPubblEsitoDMY
                                           FROM DOCUMENT_RISULTATODIGARA e WITH(NOLOCK) 
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
                 AND iSubType = '179'
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
                     , f.IdMittente
                     , f.TipoAppalto
                     , ISNULL(cag.DMV_COD, '')  AS CriterioAggiudicazioneGara
                     , f.ProtocolloBando
					 , f.Protocol as CigAusiliare

					 , CASE f.TipoBando
							WHEN 3 then 'INVITO'
							ELSE 'APERTA'
					   END as TipoProcedura

                     , Object_Cover1 AS Oggetto

                     , dbo.FormatMoney(ImportoBaseAsta) AS a_base_asta
                     , dbo.FormatMoney(esito.ValoreContratto) AS di_aggiudicazione
					 , convert ( datetime, case when ISDATE(f.ReceivedDataMsg) = 1 then f.ReceivedDataMsg else null end, 126) AS DtPubblicazione
                     , dbo.GETDATEDDMMYYYY (f.ExpiryDate) AS DtScadenzaBando 
					 , convert ( datetime, f.ExpiryDate , 126 ) AS DtScadenzaBandoTecnical 
                     , esito.DtScadenzaPubblEsitoDMY AS DtScadenzaPubblEsito
                     , f.CIG
					 , f.TipoBando

					 ,	CASE CHARINDEX ('<AFLinkFieldDivisione_Lotti>', CAST(tabM.MSGTEXT AS VARCHAR(8000))) 
                                    WHEN 0 THEN ''
                                    ELSE dbo.GetField(SUBSTRING (tabM.MSGTEXT, CHARINDEX ('<AFLinkFieldDivisione_Lotti>', CAST(tabM.MSGTEXT AS VARCHAR(8000))) + 28, 50)) 
						END AS divisioneInLotti

					, cast(f.iType as varchar(10)) + ';' + cast(f.iSubType as varchar(10))  as TipoDoc
					, f.proceduraGara as CodTipoProcedura

                  FROM TAB_MESSAGGI_FIELDS f WITH(NOLOCK)
						INNER JOIN tab_messaggi tabM ON tabM.idMsg = f.idMsg
						INNER JOIN TAB_UTENTI_MESSAGGI um WITH(NOLOCK) ON um.umIdMsg  = f.idmsg
						LEFT OUTER JOIN LIB_DomainValues cag ON cag.DMV_CodExt = CriterioAggiudicazioneGara AND cag.DMV_DM_ID = 'Criterio' 
						LEFT OUTER JOIN ( SELECT mfOUT.mfIdMsg AS ID_MSG_BANDO
                                  , CONVERT(VARCHAR(10), DataPubbEsito, 103) AS DataPubbEsito
                                  , ValoreContratto 
                                  , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                                  , CONVERT(VARCHAR(10), DATEADD(day, 180, DataPubbEsito), 103)  AS DtScadenzaPubblEsitoDMY
                               FROM DOCUMENT_RISULTATODIGARA e WITH(NOLOCK) 
                              INNER JOIN TAB_MESSAGGI_FIELDS ON e.ID_MSG_BANDO = IdMsg AND RTRIM(LTRIM(AdvancedState)) IN ('', '0')
                              INNER JOIN MessageFields mfIN WITH(NOLOCK) ON e.ID_MSG_BANDO = mfIN.mfIdMsg
                              INNER JOIN MessageFields mfOUT WITH(NOLOCK) ON mfOUT.mfFieldValue = mfIN.mfFieldValue AND mfOUT.mfIType = mfIN.mfIType 
                                    AND mfOUT.mfFieldName = mfIN.mfFieldName
                                    AND mfOUT.mfFieldName = 'IdDoc' 
                              INNER JOIN TAB_UTENTI_MESSAGGI WITH(NOLOCK) ON mfOUT.mfIdMsg = umIdMsg 
                                    AND umStato = 0 
                                    AND umInput = CAST(0 AS BIT)
                              WHERE mfOUT.mfISubType <> mfIN.mfISubType
                              UNION
                              SELECT ID_MSG_BANDO
                                   , CONVERT(VARCHAR(10), DataPubbEsito, 103) AS DataPubbEsito
                                   , ValoreContratto 
                                   , DATEADD(day, 180, DataPubbEsito) AS DtScadenzaPubblEsito
                                   , CONVERT(VARCHAR(10), DATEADD(day, 180, DataPubbEsito), 103)  AS DtScadenzaPubblEsitoDMY
                               FROM DOCUMENT_RISULTATODIGARA e      WITH(NOLOCK)                          
                           
                             ) AS esito ON umIdMsg = ID_MSG_BANDO

                 WHERE 
					UM.umStato = 0
                   AND UM.umInput = 0
                   AND AdvancedState <> '6'
                   --AND IdDoc NOT IN (SELECT JumpCheck FROM CTL_DOC WHERE TipoDoc = 'BANDO_NON_VIS' AND Deleted=0)
				   AND iSubType = '167' 
				   AND F.Stato='2'
				   AND ((f.ProceduraGara = '15476') OR (f.ProceduraGara IN ('15477', '15478') AND f.TipoBando = '3') )



) AS a 
  INNER JOIN ProfiliUtente p WITH(NOLOCK)  ON a.IdMittente = p.IdPfu
  INNER JOIN Aziende azi WITH(NOLOCK)  ON azi.IdAzi = p.pfuIdAzi
  INNER JOIN Dm_Attributi dm WITH(NOLOCK)  ON dm.lnk = azi.idazi and dm.dztnome = 'codicefiscale' and dm.idApp = 1

	  --LEFT OUTER JOIN (
			--			select dmv_descml, dmv_cod from 
			--				lib_domainvalues where dmv_dm_id = 'TipoDiAmministr'
			--		 ) as viewTipoAmmin2 on viewTipoAmmin2.dmv_cod = azi.TipoDiAmministr


WHERE a.ProtocolloBando NOT LIKE 'Demo%'




















GO
