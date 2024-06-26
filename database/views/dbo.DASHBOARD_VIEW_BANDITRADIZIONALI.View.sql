USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_BANDITRADIZIONALI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_BANDITRADIZIONALI]  AS

SELECT IdMsg
	 , umIdPfu AS IdPfu
     , msgIType
     , msgISubType
	, CASE CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) 
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 400)) 
       END AS Name
     , CASE CHARINDEX ('<AFLinkFieldIdDoc>', CAST(MSGTEXT AS VARCHAR(8000))) 
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldIdDoc>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 400)) 
       END AS IdDoc
     
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
            ELSE       
				       CASE CHARINDEX ('<AFLinkFieldNumProduct_BANDO_rettifiche>', CAST(MSGTEXT AS VARCHAR(8000)))
                            WHEN 0 THEN dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldObject_Cover1>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 300)) 
		                    ELSE  
								case dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldNumProduct_BANDO_rettifiche>', CAST(MSGTEXT AS VARCHAR(8000))) + 40, 25)) 
									when '0' then dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldObject_Cover1>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 300)) 
									else '<b>Bando Rettificato - </b> '  + dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldObject_Cover1>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 300)) 
								end
                       END
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

, CASE CHARINDEX ('<AFLinkFieldProceduraGaraTradizionale>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProceduraGaraTradizionale>', CAST(MSGTEXT AS VARCHAR(8000))) + 38, 25)) 
       END AS tipoprocedura
, CASE CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 25)) 
       END AS StatoGD
, CASE CHARINDEX ('<AFLinkFieldCriterioAggiudicazioneGara>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
			ELSE dbo.GetCodFromCodExt('Criterio',dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldCriterioAggiudicazioneGara>', CAST(MSGTEXT AS VARCHAR(8000))) + 39, 25)) )
       END AS CriterioAggiudicazione,
CASE WHEN Id IS NULL THEN 0 
            ELSE Id 
       END AS IDDOCR 
 , CASE WHEN Id IS NULL THEN 0 
           ELSE 1 
       END AS Precisazioni,
 '1' as Opendettaglio,

isnull(v.NumeroQuesiti,'') as NumeroQuesiti

 FROM 
tab_utenti_messaggi 
  LEFT OUTER JOIN  tab_messaggi  ON umIdMsg = IdMsg AND umStato = 0
LEFT OUTER JOIN 
( select cast(count(*) as varchar(10)) as NumeroQuesiti,ID_ORIGIN from 
document_chiarimenti
group by ID_ORIGIN) V ON v.ID_ORIGIN = idmsg AND msgISubType = 179

RIGHT OUTER JOIN 
(select id,a.mfidmsg from 
DOCUMENT_RISULTATODIGARA,
DOCUMENT_RISULTATODIGARA_ROW,
messagefields a,
messagefields b,
tab_utenti_messaggi c,
tab_messaggi
where 
id=idHeader 
and ID_MSG_BANDO=b.mfidmsg
and b.mfisubtype=180
and b.mffieldname='IdDoc'
and a.mfisubtype=179
and a.mffieldname='IdDoc'
and a.mffieldvalue=b.mffieldvalue
and c.uminput=0
and c.umstato=0
and c.umidmsg=a.mfidmsg
and idmsg=b.mfidmsg
and dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldAdvancedState>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 40))  <> '6'
) Q ON Q.mfidmsg  = idmsg


union 

SELECT IdMsg
	 , umIdPfu AS IdPfu
     , msgIType
     , msgISubType
	, CASE CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) 
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 400)) 
       END AS Name
     , CASE CHARINDEX ('<AFLinkFieldIdDoc>', CAST(MSGTEXT AS VARCHAR(8000))) 
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldIdDoc>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 400)) 
       END AS IdDoc
     
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
            ELSE       
				       CASE CHARINDEX ('<AFLinkFieldNumProduct_BANDO_rettifiche>', CAST(MSGTEXT AS VARCHAR(8000)))
                            WHEN 0 THEN dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldObject_Cover1>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 300)) 
		                    ELSE  
								case dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldNumProduct_BANDO_rettifiche>', CAST(MSGTEXT AS VARCHAR(8000))) + 40, 25)) 
									when '0' then dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldObject_Cover1>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 300)) 
									else '<b>Bando Rettificato - </b> '  + dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldObject_Cover1>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 300)) 
								end
                       END
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

, CASE CHARINDEX ('<AFLinkFieldProceduraGaraTradizionale>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProceduraGaraTradizionale>', CAST(MSGTEXT AS VARCHAR(8000))) + 38, 25)) 
       END AS tipoprocedura
, CASE CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
            ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 25)) 
       END AS StatoGD
, CASE CHARINDEX ('<AFLinkFieldCriterioAggiudicazioneGara>', CAST(MSGTEXT AS VARCHAR(8000)))
            WHEN 0 THEN ''
			ELSE dbo.GetCodFromCodExt('Criterio',dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldCriterioAggiudicazioneGara>', CAST(MSGTEXT AS VARCHAR(8000))) + 39, 25)) )
       END AS CriterioAggiudicazione,
   0 AS IDDOCR ,  
	0 AS Precisazioni,
 '1' as Opendettaglio,

isnull(v.NumeroQuesiti,'') as NumeroQuesiti

 FROM 
 
 tab_utenti_messaggi 
LEFT OUTER JOIN
 tab_messaggi ON umIdMsg = IdMsg  AND umStato = 0 AND msgISubType = 179
LEFT OUTER JOIN 
( select cast(count(*) as varchar(10)) as NumeroQuesiti,ID_ORIGIN from 
document_chiarimenti
group by ID_ORIGIN) V ON idmsg = v.ID_ORIGIN AND msgISubType = 179 where idmsg not in 
(select a.mfidmsg  from 
DOCUMENT_RISULTATODIGARA,
DOCUMENT_RISULTATODIGARA_ROW,
messagefields a,
messagefields b,
tab_utenti_messaggi c,
tab_messaggi
where 
id=idHeader 
and ID_MSG_BANDO=b.mfidmsg
and b.mfisubtype=180
and b.mffieldname='IdDoc'
and a.mfisubtype=179
and a.mffieldname='IdDoc'
and a.mffieldvalue=b.mffieldvalue
and c.uminput=0
and c.umstato=0
and c.umidmsg=a.mfidmsg
and idmsg=b.mfidmsg
and dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldAdvancedState>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 40))  <> '6'
)




GO
