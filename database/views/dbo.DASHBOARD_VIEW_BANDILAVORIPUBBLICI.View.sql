USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_BANDILAVORIPUBBLICI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_BANDILAVORIPUBBLICI]  AS
SELECT M.IdMsg
     ,'0' as Scaduto
     , umIdPfu AS IdPfu
     , msgIType
     , msgISubType
    
     ,TMF.Name
   
     ,TMF.ProtocolloBando
    
     ,TMF.ProtocolloOfferta
  
     ,TMF.ReceivedDataMsg
     
    
    , CASE NumProduct_BANDO_rettifiche
        WHEN '' THEN Object_Cover1
		WHEN '0' THEN Object_Cover1
		ELSE  '<Strong style="font-size:14px">Bando Rettificato - </Strong> '  + Object_Cover1
	  END + '&nbsp;' AS Oggetto  
  
    , CASE TMF.tipoappalto
		WHEN '' THEN ''
		ELSE dbo.GetCodFromCodExt('Tipologia',TMF.tipoappalto )
	 END AS Tipologia
    
     ,TMF.ExpiryDate

      ,TMF.ExpiryDate as expirydateAl

  
      ,TMF.ImportoBaseAsta

, CASE ProceduraGara
				WHEN '' THEN ''
				ELSE dbo.GetCodFromCodExt('TipoProcedura',ProceduraGara )
	  END AS tipoprocedura

, TMF.Stato AS StatoGD

,TMF.ProtocolBG as Fascicolo

 ,CASE AggiudicazioneGara
            WHEN '' THEN ''
			ELSE dbo.GetCodFromCodExt('Criterio',AggiudicazioneGara )
       END AS CriterioAggiudicazione
 , CASE CriterioFormulazioneOfferte
            WHEN '' THEN ''
			ELSE dbo.GetCodFromCodExt('CriterioOfferte',CriterioFormulazioneOfferte )
      END AS CriterioFormulazioneOfferta


 ,CASE WHEN Id IS NULL THEN 0 
            ELSE Id 
       END AS IDDOC 
 
 , Id as IDDOCR

 , CASE WHEN Id IS NULL THEN 0 
           ELSE 1 
       END AS Precisazioni,

 '1' as OpenDettaglio
 ,TMF.RagSoc as EnteAppaltante
 ,TMF.FaseGara
 ,TMF.ModalitadiPartecipazione
 ,TMF.CIG

 FROM 
multilinguismo, 
folderdocuments, 
foldertypes, 
document,  
msgpermissions, 
tab_utenti_messaggi, 
tab_messaggi M,
tab_messaggi_fields TMF ,
DOCUMENT_RISULTATODIGARA,
DOCUMENT_RISULTATODIGARA_ROW

WHERE 

ftidpf = fdidpf 
	and fdidpfu = mpidpfu  
	and fdIdMsg = mpIdMsg 
	and umIdMsg = M.IdMsg  
	and fdIdMsg = umIdMsg 
	and upper(rtrim(dcmDescription)) = upper(rtrim(idmultilng))  
	and fdIdPf = 34
	and msgIType = dcmIType  
	and msgISubType = dcmISubType  
	and ftiddcm = iddcm  
	and umIdPfu = -10 
	and ftdeleted = 0  
	and dcmDeleted = 0  
	and mpidPfu = -10
 	and id=idHeader
    AND M.IdMsg = ID_MSG_BANDO
    and TMF.IdMsg = M.IdMsg 
    and  EvidenzaPubblica=1
    and dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldAdvancedState>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 40))  <> '6'
    and TMF.iddoc not in (select JumpCheck from CTL_DOC where TipoDoc='BANDO_NON_VIS' and Deleted=0)

UNION 

SELECT M.IdMsg
     ,'0' as Scaduto
     , umIdPfu AS IdPfu
     , msgIType
     , msgISubType
   
        ,TMF.Name

       ,TMF.ProtocolloBando
  
     ,TMF.ProtocolloOfferta
  
     ,TMF.ReceivedDataMsg
  

    , CASE NumProduct_BANDO_rettifiche
        WHEN '' THEN Object_Cover1
		WHEN '0' THEN Object_Cover1
		ELSE  '<Strong style="font-size:14px">Bando Rettificato - </Strong> '  + Object_Cover1
	  END + '&nbsp;' AS Oggetto  

    , CASE TMF.tipoappalto
		WHEN '' THEN ''
		ELSE dbo.GetCodFromCodExt('Tipologia',TMF.tipoappalto )
	  END AS Tipologia
    
         ,TMF.ExpiryDate

   ,TMF.ExpiryDate as expirydateAl
    
    ,TMF.ImportoBaseAsta
 
   , CASE ProceduraGara
				WHEN '' THEN ''
				ELSE dbo.GetCodFromCodExt('TipoProcedura',ProceduraGara )
	  END AS tipoprocedura
   , TMF.Stato AS StatoGD

,TMF.ProtocolBG as Fascicolo

,CASE AggiudicazioneGara
            WHEN '' THEN ''
			ELSE dbo.GetCodFromCodExt('Criterio',AggiudicazioneGara )
       END AS CriterioAggiudicazione
 , CASE CriterioFormulazioneOfferte
            WHEN '' THEN ''
			ELSE dbo.GetCodFromCodExt('CriterioOfferte',CriterioFormulazioneOfferte )
      END AS CriterioFormulazioneOfferta,


 0 AS IDDOC ,  
 0 AS IDDOCR, 
 0 AS Precisazioni,
 
'1' as OpenDettaglio
,TMF.RagSoc as EnteAppaltante
,TMF.FaseGara
,TMF.ModalitadiPartecipazione
,TMF.CIG
 FROM 
multilinguismo, 
folderdocuments, 
foldertypes, 
document,  
msgpermissions, 
tab_utenti_messaggi, 
tab_messaggi M,
tab_messaggi_fields TMF 

WHERE 

ftidpf = fdidpf 
	and fdidpfu = mpidpfu  
	and fdIdMsg = mpIdMsg 
	and umIdMsg = M.IdMsg  
	and fdIdMsg = umIdMsg 
	and upper(rtrim(dcmDescription)) = upper(rtrim(idmultilng))  
	and fdIdPf = 34
	and msgIType = dcmIType  
	and msgISubType = dcmISubType  
	and ftiddcm = iddcm  
	and umIdPfu = -10 
	and ftdeleted = 0  
	and dcmDeleted = 0  
	and mpidPfu = -10
	and dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldAdvancedState>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 40))  <> '6'
    and TMF.IdMsg = M.IdMsg  
    and  (EvidenzaPubblica=1 or EvidenzaPubblica IS NULL)
    AND M.IdMsg not in 
( select ID_MSG_BANDO from DOCUMENT_RISULTATODIGARA,DOCUMENT_RISULTATODIGARA_ROW
  where id=idheader)
  and TMF.iddoc not in (select JumpCheck from CTL_DOC where TipoDoc='BANDO_NON_VIS' and Deleted=0)





UNION ALL

SELECT M.IdMsg
    ,'0' as Scaduto
	, umIdPfu AS IdPfu
	, msgIType
	, msgISubType
	, Name
	, TMF.ProtocolloBando
	, ProtocolloOfferta
	, ReceivedDataMsg

	, CASE NumProduct_BANDO_rettifiche
		WHEN '' THEN Object_Cover1
		WHEN '0' THEN Object_Cover1
		ELSE  '<Strong style="font-size:14px">Bando Rettificato - </Strong> '  + Object_Cover1
	  END + '&nbsp;' AS Oggetto

	, CASE tipoappalto
		WHEN '' THEN ''
		ELSE dbo.GetCodFromCodExt('Tipologia',tipoappalto )
	END AS Tipologia

	,TMF.ExpiryDate

	,TMF.ExpiryDate as expirydateAl

    , TMF.ImportoBaseAsta

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
     
	,0 as IdDoc

     --,0 AS Precisazioni
   ,CASE WHEN Id IS NULL THEN 0 
			ELSE Id 
		END AS IDDOCR

	, CASE WHEN Id IS NULL THEN 0 
           ELSE 1 
       END AS Precisazioni

     

	 , '1' as OpenDettaglio
	 ,TMF.RagSoc as EnteAppaltante
     ,TMF.FaseGara
     ,TMF.ModalitadiPartecipazione
     ,TMF.CIG

	
 
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
	and msgISubType in (167)
	and msgIType = 55
	and M.IdMsg = TMF.Idmsg
	and uminput=0
	and umstato=0
	and umidpfu > 0
    and M.idmsg=mfidmsg
	and mffieldname='IdDoc'
	and TMF.TipoBando=3
	and TMF.EvidenzaPubblica=1
	and TMF.iddoc not in (select JumpCheck from CTL_DOC where TipoDoc='BANDO_NON_VIS' and Deleted=0)
    and TMF.stato=2
GO
