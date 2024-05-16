USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_BANDILAVORI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_BANDILAVORI] AS
select * from (
        SELECT    
        	dbo.TAB_MESSAGGI.IdMsg, 
        	dbo.TAB_UTENTI_MESSAGGI.umIdPfu AS IdPfu, 
        	dbo.TAB_MESSAGGI.msgiType, 
        	dbo.TAB_MESSAGGI.msgiSubType, 
        	CASE CHARINDEX('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldName>', CAST(MSGTEXT AS VARCHAR(8000))) + 17, 400)) END AS Name,
        	CASE CHARINDEX('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 20)) END AS ProtocolloBando,
        	--CASE CHARINDEX('<AFLinkFieldProtocolloOfferta>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldProtocolloOfferta>', CAST(MSGTEXT AS VARCHAR(8000))) + 30, 20)) END AS ProtocolloOfferta, 
        	CASE CHARINDEX('<AFLinkFieldReceivedDataMsg>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldReceivedDataMsg>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 25)) END AS ReceivedDataMsg,
        	CASE CHARINDEX('<AFLinkFieldObject_Cover1>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldObject_Cover1>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 300)) END AS Oggetto, 
        	--CASE CHARINDEX('<AFLinkFieldtipoappalto>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetCodFromCodExt('Tipologia', dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldtipoappalto>', CAST(MSGTEXT AS VARCHAR(8000))) + 24, 25))) END AS Tipologia,
        	CASE CHARINDEX('<AFLinkFieldExpiryDate>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldExpiryDate>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 25)) END AS expirydate,
        	CASE CHARINDEX('<AFLinkFieldImportoBaseAsta>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldImportoBaseAsta>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 25)) END AS ImportoBaseAsta, 
        	--CASE CHARINDEX('<AFLinkFieldProceduraGara>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetCodFromCodExt('TipoProcedura', dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldProceduraGara>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 25))) END AS tipoprocedura, 
        	CASE CHARINDEX('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 25)) END AS StatoGD,
        	CASE CHARINDEX('<AFLinkFieldDataAperturaOfferte>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldDataAperturaOfferte>', CAST(MSGTEXT AS VARCHAR(8000))) + 32, 25)) END AS DataAperturaOfferte,
        	case when CASE CHARINDEX('<AFLinkFieldDataIISeduta>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldDataIISeduta>', CAST(MSGTEXT AS VARCHAR(8000))) + 25, 25)) END = 'T00:00:00' then '' 
        		else	CASE CHARINDEX('<AFLinkFieldDataIISeduta>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldDataIISeduta>', CAST(MSGTEXT AS VARCHAR(8000))) + 25, 25)) END end AS DataIISeduta
        	--CASE CHARINDEX('<AFLinkFieldProtocolBG>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldProtocolBG>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 25)) END AS Fascicolo, 
        	--CASE CHARINDEX('<AFLinkFieldCriterioAggiudicazioneGara>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetCodFromCodExt('Criterio', dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldCriterioAggiudicazioneGara>', CAST(MSGTEXT AS VARCHAR(8000))) + 39, 25))) END AS CriterioAggiudicazione, 
        	--CASE CHARINDEX('<AFLinkFieldCriterioFormulazioneOfferte>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetCodFromCodExt('CriterioOfferte', dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldCriterioFormulazioneOfferte>', CAST(MSGTEXT AS VARCHAR(8000))) + 40, 25))) END AS CriterioFormulazioneOfferta
        FROM         dbo.TAB_MESSAGGI 
INNER JOIN dbo.TAB_UTENTI_MESSAGGI ON dbo.TAB_MESSAGGI.IdMsg = dbo.TAB_UTENTI_MESSAGGI.umIdMsg
        WHERE     (dbo.TAB_UTENTI_MESSAGGI.umIdPfu = - 10) 
AND (dbo.TAB_MESSAGGI.msgiType = 55) AND (dbo.TAB_MESSAGGI.msgiSubType = 168)
                and  TAB_MESSAGGI.IdMsg  in (
                        select max(IdMsg ) idMsg from (
                                select 	dbo.TAB_MESSAGGI.IdMsg ,
                                	CASE CHARINDEX('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000))) WHEN 0 THEN '' ELSE dbo.GetField(SUBSTRING(MSGTEXT, CHARINDEX('<AFLinkFieldProtocolloBando>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 20)) END AS ProtocolloBando
                                FROM         dbo.TAB_MESSAGGI 
INNER JOIN dbo.TAB_UTENTI_MESSAGGI ON dbo.TAB_MESSAGGI.IdMsg = dbo.TAB_UTENTI_MESSAGGI.umIdMsg
WHERE     (dbo.TAB_UTENTI_MESSAGGI.umIdPfu = - 10) AND (dbo.TAB_MESSAGGI.msgiType = 55) 
AND (dbo.TAB_MESSAGGI.msgiSubType = 168) and umstato = 0
                        ) as a
                        group by  ProtocolloBando
                )
        ) as a
GO
