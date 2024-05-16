USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_INVITI_PROGETTI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_INVITI_PROGETTI]  AS
--Versione=2&data=2014-01-27&Attivita=52020&Nominativo=Enrico
SELECT tm.IdMsg
     , umIdPfu AS IdPfu
     , msgIType
     , msgISubType
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
    , CASE CHARINDEX ('<AFLinkFieldObject_Cover1>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldObject_Cover1>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 90)) 
		+ '&nbsp;'
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
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldImportoBaseAsta>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 25)) 
       END AS ImportoBaseAsta

, CASE CHARINDEX ('<AFLinkFieldProceduraGara>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetCodFromCodExt('TipoProcedura',dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProceduraGara>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 25)) )
       END AS tipoprocedura
, CASE CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 25)) 
       END AS StatoGD
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

      , CASE CHARINDEX ('<AFLinkFieldExpiryDate>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN '0'
            ELSE case when dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldExpiryDate>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 25)) < convert( varchar(30) , getdate() , 126 ) then '1' else '0' end
       END AS Scaduto
, CASE CHARINDEX ('<AFLinkFieldIdDoc>', CAST(MSGTEXT AS VARCHAR(8000))) 
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldIdDoc>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 400)) 
       END AS IdDoc
 FROM 

multilinguismo, 
document,  
tab_utenti_messaggi tu, 
tab_messaggi tm,
tab_messaggi_fields tmf

WHERE  umIdMsg = tm.IdMsg  
	and upper(rtrim(dcmDescription)) = upper(rtrim(idmultilng))  
	and msgIType = dcmIType  
	and msgISubType = dcmISubType  
	and dcmDeleted = 0  
	and ( msgISubType = 20 or (msgISubType = 167 and tipobando='3') )
	and uminput=0
	and umstato=0
	and umidpfu > 0
        and tmf.idmsg=tm.idmsg
GO
