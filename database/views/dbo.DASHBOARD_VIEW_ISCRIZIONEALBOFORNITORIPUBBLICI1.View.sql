USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORIPUBBLICI1]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORIPUBBLICI1]  AS
SELECT IdMsg
     , umIdPfu AS IdPfu
     , msgIType
     , msgISubType
     , CASE CHARINDEX ('<AFLinkFieldIdMittente>', CAST(MSGTEXT AS VARCHAR(8000))) 
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldIdMittente>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 400)) 
       END AS IdMittente
     
     , CASE CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) 
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 400)) 
       END AS Name
     
	, CASE CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 20)) 
       END AS ProtocolloBando
     , CASE CHARINDEX ('<AFLinkFieldProtocolloOfferta>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolloOfferta>', CAST(MSGTEXT AS VARCHAR(8000))) + 30, 20)) 
       END AS ProtocolloOfferta
     , CASE CHARINDEX ('<AFLinkFieldReceivedDataMsg>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldReceivedDataMsg>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 25)) 
       END AS ReceivedDataMsg
    , CASE CHARINDEX ('<AFLinkFieldObject>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldObject>', CAST(MSGTEXT AS VARCHAR(8000))) + 19, 90)) 
       END AS Oggetto
, CASE CHARINDEX ('<AFLinkFieldtipoappalto>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
			ELSE dbo.GetCodFromCodExt('Tipologia',dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldtipoappalto>', CAST(MSGTEXT AS VARCHAR(8000))) + 24, 25)) )
       END AS Tipologia
      , CASE CHARINDEX ('<AFLinkFieldExpiryDate>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldExpiryDate>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 25)) 
       END AS expirydate

      , CASE CHARINDEX ('<AFLinkFieldImportoBaseAsta>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldImportoBaseAsta>', CAST(MSGTEXT AS VARCHAR(8000))) + 29, 25)) 
       END AS ImportoBaseAsta

, CASE CHARINDEX ('<AFLinkFieldProceduraGara>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetCodFromCodExt('TipoProcedura',dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProceduraGara>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 25)) )
       END AS tipoprocedura
, CASE CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 25)) 
       END AS Stato
, CASE CHARINDEX ('<AFLinkFieldProtocolBG>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolBG>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 25)) 
       END AS Fascicolo
, CASE CHARINDEX ('<AFLinkFieldCriterioAggiudicazioneGara>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
			ELSE dbo.GetCodFromCodExt('Criterio',dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldCriterioAggiudicazioneGara>', CAST(MSGTEXT AS VARCHAR(8000))) + 39, 25)) )
       END AS CriterioAggiudicazione

, CASE CHARINDEX ('<AFLinkFieldCriterioFormulazioneOfferte>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
			ELSE dbo.GetCodFromCodExt('CriterioOfferte',dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldCriterioFormulazioneOfferte>', CAST(MSGTEXT AS VARCHAR(8000))) + 40, 25)) )
       END AS CriterioFormulazioneOfferta,
'1' as OpenDettaglio

 FROM 
multilinguismo, 
folderdocuments, 
foldertypes, 
document,  
msgpermissions, 
tab_utenti_messaggi, 
tab_messaggi
WHERE 

ftidpf = fdidpf 
	and fdidpfu = mpidpfu  
	and fdIdMsg = mpIdMsg 
	and umIdMsg = IdMsg  
	and fdIdMsg = umIdMsg 
	and upper(rtrim(dcmDescription)) = upper(rtrim(idmultilng))  
	and fdIdPf = 12
	and msgIType = dcmIType  
	and msgISubType = dcmISubType  
	and ftiddcm = iddcm  
	and umIdPfu = -10 
	and ftdeleted = 0  
	and dcmDeleted = 0  
	and mpidPfu = -10


GO
