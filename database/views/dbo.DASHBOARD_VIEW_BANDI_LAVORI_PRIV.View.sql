USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_BANDI_LAVORI_PRIV]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_BANDI_LAVORI_PRIV]  AS
SELECT M.IdMsg
	, umIdPfu AS IdPfu
	, msgIType
	, msgISubType

	,CASE WHEN Id IS NULL THEN 0 
		ELSE Id 
	END AS IDDOCR 

	,CASE WHEN Id IS NULL THEN 0 
	   ELSE 1 
	END AS Precisazioni

	, Name
	, [read] as  bRead
	, TMF.ProtocolloBando
	--, TMF.TipoBando
	, ProtocolloOfferta
	, ReceivedDataMsg

	, CASE NumProduct_BANDO_rettifiche
		WHEN '' THEN Object_Cover1
		WHEN '0' THEN Object_Cover1
		ELSE  '<b>Bando Rettificato - </b> '  + Object_Cover1
	  END + '&nbsp;' AS Oggetto

	, CASE tipoappalto
		WHEN '' THEN ''
		ELSE dbo.GetCodFromCodExt('Tipologia',tipoappalto )
	END AS Tipologia

	, CASE ExpiryDate
		WHEN '' THEN ''
		ELSE 
			case msgISubType	
				when '79' then DataFineAsta
				when '113' then DataFineAsta
				when '153' then DataFineAsta
				else ExpiryDate
			end 
	END AS expirydate

    , case msgISubType	
				when '21' then ImportoAppalto
				when '79' then ImportoAppalto
				when '113' then ImportoAppalto
				when '153' then ImportoAppalto
				else ImportoBaseAsta
			  
	  END AS ImportoBaseAsta

	, CASE ProceduraGara
				WHEN '' THEN ''
				ELSE dbo.GetCodFromCodExt('TipoProcedura',ProceduraGara )
	  END AS tipoprocedura

	, Stato AS StatoGD
	, ProtocolBG as Fascicolo

	, CASE AggiudicazioneGara
            WHEN '' THEN ''
			ELSE dbo.GetCodFromCodExt('Criterio',AggiudicazioneGara )
       END AS CriterioAggiudicazione

	, CASE CriterioFormulazioneOfferte
            WHEN '' THEN ''
			ELSE dbo.GetCodFromCodExt('CriterioOfferte',CriterioFormulazioneOfferte )
      END AS CriterioFormulazioneOfferta

	, '1' as OpenDettaglio

    ,  '0' as Scaduto

	, TMF.IdDoc
 
FROM 

multilinguismo, 
document,  
tab_utenti_messaggi tu, 
tab_messaggi M,
tab_messaggi_fields TMF,

(select distinct id , mfFieldValue as IdDoc from 
DOCUMENT_RISULTATODIGARA,DOCUMENT_RISULTATODIGARA_ROW,
messagefields where idheader=id and mfidmsg=id_msg_bando  and mfFieldName='IdDoc') V 
right outer join messagefields mf on v.iddoc = mf.mffieldvalue
 
WHERE  umIdMsg = M.IdMsg  
	and upper(rtrim(dcmDescription)) = upper(rtrim(idmultilng))  
	and msgIType = dcmIType  
	and msgISubType = dcmISubType  
	and dcmDeleted = 0  
	and msgISubType in (168)
	and msgIType = 55
	and M.IdMsg = TMF.Idmsg
	and uminput=0
	and umstato=0
	and umidpfu > 0
    and M.idmsg=mfidmsg
	and mffieldname='IdDoc'
	and  
	     (
	     (ProceduraGara=15477 and TipoBando=3 ) or
	     ((ProceduraGara=15475 or ProceduraGara=15478) and TipoBando=3)
	      )
GO
