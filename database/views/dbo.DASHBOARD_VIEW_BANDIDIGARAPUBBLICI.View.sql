USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_BANDIDIGARAPUBBLICI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_BANDIDIGARAPUBBLICI]  AS
select 
    V.*,

   CASE WHEN Id IS NULL THEN 0 
            ELSE Id 
       END AS IDDOCR , 
   
   CASE WHEN Id IS NULL THEN 0 
           ELSE 1 
       END AS Precisazioni

 from 
(
	SELECT 
		TMF.IdMsg,
		umIdPfu AS IdPfu, msgIType, msgISubType, TMF.Name,TMF.ProtocolloBando , TMF.ProtocolloOfferta,TMF.ReceivedDataMsg
		,TMF.Object_Cover1  as Oggetto,TMF.tipoappalto as Tipologia,TMF.ExpiryDate,TMF.ImportoBaseAsta  , TMF.ProceduraGara  as tipoprocedura
		,TMF.Stato  as StatoGD, TMF.ProtocolBG   as Fascicolo ,TMF.CriterioAggiudicazioneGara   as CriterioAggiudicazione
		,TMF.CriterioFormulazioneOfferte  as CriterioFormulazioneOfferta, '1' as Opendettaglio
		
	FROM 
		multilinguismo, 
		folderdocuments, 
		foldertypes, 
		document,  
		msgpermissions, 
		tab_utenti_messaggi with(nolock) , 
		tab_messaggi TM with(nolock) ,
		tab_messaggi_fields TMF with(nolock) 
	WHERE 
	
		ftidpf = fdidpf 
		and fdidpfu = mpidpfu  
		and fdIdMsg = mpIdMsg 
		and umIdMsg = TM.IdMsg  
		and fdIdMsg = umIdMsg 
		and TMF.idmsg=TM.IdMsg
		and upper(rtrim(dcmDescription)) = upper(rtrim(idmultilng))  
		and fdIdPf = 15 
		and msgIType = dcmIType  
		and msgISubType = dcmISubType  
		and ftiddcm = iddcm  
		and umIdPfu = -10 
		and ftdeleted = 0  
		and dcmDeleted = 0  
		and mpidPfu = -10

	UNION ALL
	
	--aggiungo i documenti di tipo 55,48 nello stato inviato
	--non scaduti o con scadenza non superiore a 10 giorni
	SELECT 
		TMF.IdMsg,
		umIdPfu AS IdPfu, msgIType, msgISubType, TMF.Name,TMF.ProtocolloBando , TMF.ProtocolloOfferta,TMF.ReceivedDataMsg
		,TMF.Object_Cover1  as Oggetto,TMF.tipoappalto as Tipologia,TMF.ExpiryDate,TMF.ImportoBaseAsta  , TMF.ProceduraGara  as tipoprocedura
		,TMF.Stato  as StatoGD, TMF.ProtocolBG   as Fascicolo ,TMF.CriterioAggiudicazioneGara   as CriterioAggiudicazione
		,TMF.CriterioFormulazioneOfferte  as CriterioFormulazioneOfferta, '1' as Opendettaglio
	
	FROM 
		tab_utenti_messaggi with(nolock) , 
		tab_messaggi TM with(nolock) ,
		tab_messaggi_fields TMF with(nolock) 
	WHERE 
		umIdMsg = TMF.IdMsg  
		and TMF.IdMsg = TM.IdMsg 
		and msgIType = 55  
		and msgISubType = 48
		and uminput=0
		and umstato=0
		and TMF.Stato ='2'
		and replace( TMF.ExpiryDate ,'T',' ') > dateadd(year,-1,getdate())


	UNION ALL

	--aggiungo i documenti di tipo 55,78 nello stato inviato
	--non scaduti o con scadenza non superiore a 10 giorni

	SELECT 
		
		TMF.IdMsg,
		umIdPfu AS IdPfu, msgIType, msgISubType, TMF.Name,TMF.ProtocolloBando , TMF.ProtocolloOfferta,TMF.ReceivedDataMsg
		,TMF.Object_Cover1  as Oggetto,TMF.tipoappalto as Tipologia,TMF.ExpiryDate,TMF.ImportoBaseAsta  , TMF.ProceduraGara  as tipoprocedura
		,TMF.Stato  as StatoGD, TMF.ProtocolBG   as Fascicolo ,TMF.CriterioAggiudicazioneGara   as CriterioAggiudicazione
		,TMF.CriterioFormulazioneOfferte  as CriterioFormulazioneOfferta, '1' as Opendettaglio
		
	

	FROM 
		tab_utenti_messaggi with(nolock) , 
		tab_messaggi TM with(nolock) ,
		tab_messaggi_fields TMF with(nolock) 
	WHERE 

		umIdMsg = TMF.IdMsg  
		and TMF.IdMsg = TM.IdMsg 
		and msgIType = 55  
		and msgISubType = 78
		and uminput=0
		and umstato=0
		and  TMF.Stato ='2'
		and  TMF.AuctionState <>'3'
		and replace( TMF.DataFineAsta ,'T',' ') > dateadd(year,-1,getdate())

	UNION ALL
	--documenti di tipo 168 pubblici
	SELECT  
		TMF.IdMsg,
		umIdPfu AS IdPfu, msgIType, msgISubType, TMF.Name,TMF.ProtocolloBando , TMF.ProtocolloOfferta,TMF.ReceivedDataMsg
		,TMF.Object_Cover1  as Oggetto,TMF.tipoappalto as Tipologia,TMF.ExpiryDate,TMF.ImportoBaseAsta  , TMF.ProceduraGara  as tipoprocedura
		,TMF.Stato  as StatoGD, TMF.ProtocolBG   as Fascicolo ,TMF.CriterioAggiudicazioneGara   as CriterioAggiudicazione
		,TMF.CriterioFormulazioneOfferte  as CriterioFormulazioneOfferta, '1' as Opendettaglio

	FROM 
			tab_utenti_messaggi with(nolock) , 
			tab_messaggi TM  with(nolock) , 
			tab_messaggi_fields TMF   with(nolock) 
	WHERE 
			umIdMsg = TM.IdMsg AND 
			TM.IdMsg = TMF.IdMsg AND 
			umIdPfu=-10 AND 
			msgIType = 55 AND 
			msgISubType = 168 and 
			(EvidenzaPubblica=1 or EvidenzaPubblica IS NULL)

	UNION ALL
	--documenti di tipo 167 inviti
	SELECT  
		TMF.IdMsg,
		umIdPfu AS IdPfu, msgIType, msgISubType, TMF.Name,TMF.ProtocolloBando , TMF.ProtocolloOfferta,TMF.ReceivedDataMsg
		,TMF.Object_Cover1  as Oggetto,TMF.tipoappalto as Tipologia,TMF.ExpiryDate,TMF.ImportoBaseAsta  , TMF.ProceduraGara  as tipoprocedura
		,TMF.Stato  as StatoGD, TMF.ProtocolBG   as Fascicolo ,TMF.CriterioAggiudicazioneGara   as CriterioAggiudicazione
		,TMF.CriterioFormulazioneOfferte  as CriterioFormulazioneOfferta, '1' as Opendettaglio

	FROM 
			tab_utenti_messaggi with(nolock) , 
			tab_messaggi TM  with(nolock) , 
			tab_messaggi_fields TMF   with(nolock) 
	WHERE 
			umIdMsg = TM.IdMsg AND 
			TM.IdMsg = TMF.IdMsg AND 
			umIdPfu>0 AND 
			msgIType = 55 AND 
			msgISubType = 167 and 
			(EvidenzaPubblica=1 or EvidenzaPubblica IS NULL)
			and TMF.TipoBando='3' AND 
			TMF.AdvancedState <> '6' and 
			TMF.Stato=2


) V LEFT OUTER JOIN DOCUMENT_RISULTATODIGARA ON V.IdMsg = ID_MSG_BANDO
--DOCUMENT_RISULTATODIGARA_ROW

where 


--and id in (select idheader from DOCUMENT_RISULTATODIGARA_ROW)
V.ProtocolloBando not like 'Demo%' and V.IdMsg not in (36059,27802,31474,30868,43812)


GO
