USE [AFLink_TND]
GO
/****** Object:  View [dbo].[X_CHIARIMENTI_PORTALE_FROM_BANDI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[X_CHIARIMENTI_PORTALE_FROM_BANDI]  AS
SELECT IdMsg AS ID_FROM
	 ,a.mfIdMsg  AS ID_ORIGIN 
     , d.umIdPfu AS IdPfu
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
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldObject_Cover1>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 100)) 
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
, CASE CHARINDEX ('<AFLinkFieldCriterioAggiudicazioneGara>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
			ELSE dbo.GetCodFromCodExt('Criterio',dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldCriterioAggiudicazioneGara>', CAST(MSGTEXT AS VARCHAR(8000))) + 39, 25)) )
       END AS CriterioAggiudicazione,
 '1' as Opendettaglio,
 CASE CHARINDEX ('<AFLinkFieldRettifica>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN 'no'
			ELSE  dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldRettifica>', CAST(MSGTEXT AS VARCHAR(8000))) + 22, 25)) 
       END AS Rettifica,
  replace(convert(varchar,getdate(),121),' ','T') as Dataodierna

 FROM 
multilinguismo, 
folderdocuments, 
foldertypes, 
document,  
msgpermissions, 
tab_utenti_messaggi c, 
tab_utenti_messaggi d, 
tab_messaggi,
messagefields a,
messagefields b
WHERE 

	ftidpf = fdidpf 
	and fdidpfu = mpidpfu  
	and fdIdMsg = mpIdMsg 
	and d.umIdMsg = IdMsg  
	and fdIdMsg = d.umIdMsg 
	and upper(rtrim(dcmDescription)) = upper(rtrim(idmultilng))  
	and fdIdPf = 36 
	and msgIType = dcmIType  
	and msgISubType = dcmISubType  
	and ftiddcm = iddcm  
	and d.umIdPfu = -10 
	and ftdeleted = 0  
	and dcmDeleted = 0  
	and mpidPfu = -10
    and dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldAdvancedState>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 40))  <> '6'
    and a.mfisubtype=179
    and a.mffieldname='IdDoc'
	and b.mfisubtype=180
    and b.mffieldname='IdDoc'
	and a.mffieldvalue=b.mffieldvalue
	and b.mfidmsg=IdMsg
	and c.uminput=0
    and c.umidmsg=a.mfidmsg

	--and dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldIdDoc>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 400))
GO
