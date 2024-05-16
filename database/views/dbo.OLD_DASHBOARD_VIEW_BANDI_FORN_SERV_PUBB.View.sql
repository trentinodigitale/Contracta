USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_BANDI_FORN_SERV_PUBB]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

			  

CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_BANDI_FORN_SERV_PUBB] AS
--Versione=8&data=2020-04-07&Attivita=296784&Nominativo=Francesco
--Versione=7&data=2017-05-23&Attivita=152818&Nominativo=Sabato
--Versione=6&data=2014-03-03&Attivita=53377&Nominativo=Enrico

--SELECT
--		V.*
--		,u.pfuIdAzi as AZI_Ente
--		,CASE 
--				WHEN DP.protocollobando is null THEN '0'
--				ELSE '1'
--		  END AS Scaduto
--		,EvidenzaPubblica
--		,'' as DOCUMENT 
--		,'' as OPEN_DOC_NAME
--		,case 
--					when v.Appalto_Verde='si' and v.Acquisto_Sociale='si' then '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">&nbsp;<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">'  
--					when v.Appalto_Verde='si' and v.Acquisto_Sociale='no' then  '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">' 
--					when v.Appalto_Verde='no' and v.Acquisto_Sociale='si' then  '<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">' 
--		end as Bando_Verde_Sociale,
--		null as Protocollo
--		, '' as SedutaVirtuale
--		,'' as EnteProponente 
--		FROM
--			(
--				SELECT
--				   IdMsg,
--				   IdPfu,
--				   msgIType,
--				   msgISubType,
--				   IDDOCR,
--				   Precisazioni,
--				   Opendettaglio,
--				   Name,
--				   IdDoc,
--				   ProtocolloBando,
--				   CIG,	 
--				   ProtocolloOfferta,
--				   ReceivedDataMsg,
----				   CASE 
----						WHEN NumProduct_BANDO_rettifiche in ('','0') then
----							case advancedstate		
----								when '6' then 	'<strong>Bando In Rettifica - </strong> '  + Object_Cover1
----								else Object_Cover1
----							end 
----
----						ELSE  '<strong>Bando Rettificato - </strong> '  + Object_Cover1
----
----					END + '&nbsp;' AS Oggetto,

--					CASE ADVANCEDSTATE
				
--						WHEN '6' then 	'<strong>Bando In Rettifica - </strong> '  + Object_Cover1
--						WHEN '7' then 	'<strong>Bando Revocato - </strong> '  + Object_Cover1
--						ELSE
--							case 
--								WHEN NumProduct_BANDO_rettifiche not in ('','0') then '<strong>Bando Rettificato - </strong> '  + Object_Cover1
--								else Object_Cover1
--							end
			
--					END + '&nbsp;' AS Oggetto,

--				   CAST(DOMTipologia.DMV_COD AS VARCHAR) AS Tipologia,

--				   ExpiryDate,
--				   ExpiryDate AS ExpiryDateAl,

--				   ImportoBaseAsta,

--				   ProceduraGaraTradizionale AS tipoprocedura,

--				   Stato AS StatoGD,

--				   DOMCriterio.DMV_COD AS CriterioAggiudicazione,

--				   RagSoc AS EnteAppaltante  ,
--				   Appalto_verde,
--				   Acquisto_Sociale,

--				   TipoBando as TipoBandoGara 
--				   , IdMittente
				   
	
--			   FROM 
--					(
--						SELECT 
--							DMV_Cod , 
--							DMV_CodExt

--							FROM LIB_DomainValues with(nolock) 
--							WHERE DMV_DM_Id = 'Tipologia'
--					) AS DOMTipologia
--					,
--					(
--						SELECT	
--							'' AS DMV_Cod ,
--							'' AS DMV_CodExt
--						UNION
--						SELECT 
--							DMV_Cod ,
--							DMV_CodExt

--							FROM LIB_DomainValues with(nolock) 
--							WHERE DMV_DM_Id = 'Criterio'
--					) AS DOMCriterio
--					 ,
--					(
--						SELECT
--							--TM.IdMsg,
--							umIdPfu AS IdPfu,
--							msgIType,
--							msgISubType,
				
--							TMF.IdMsg       ,TMF.iType       ,TMF.iSubType       ,TMF.IdDoc       ,TMF.Stato       ,TMF.AdvancedState       ,TMF.PersistenceType       ,TMF.IdMarketPlace
--							,TMF.Name       ,TMF.Protocol       ,TMF.IdMittente       ,TMF.IdDestinatario      ,TMF.[Read]      ,TMF.Data      ,TMF.ReceivedDataMsg      ,TMF.ExpiryDate
--							,TMF.ProtocolloBando      ,TMF.[Object]      ,TMF.Object_Cover1      ,TMF.ProtocolloOfferta      ,TMF.ProceduraGaraTradizionale      ,TMF.tipoappalto
--							,TMF.CriterioAggiudicazioneGara      ,TMF.AuctionState      ,TMF.DataInizioAsta      ,TMF.DataFineAsta      ,TMF.ImportoBaseAsta      ,TMF.ImportoAppalto
--							,TMF.ProceduraGara      ,TMF.ProtocolBG      ,TMF.AggiudicazioneGara      ,TMF.CriterioFormulazioneOfferte      ,TMF.NumProduct_BANDO_rettifiche
--							,TMF.RagSoc      ,TMF.ImportoBaseAsta2 , TMF.CIG,ReceivedOff,ReceivedQuesiti,TMF.TipoProcedura,
--							TMF.NameBG,TMF.TipoAsta,TMF.ReceivedDomanda,TMF.ReceivedIscrizioni,TMF.sysHabilitStartDate,TMF.FaseGara,
--							TMF.DataAperturaOfferte,TMF.DataAperturaDomande,TMF.DataIISeduta,TMF.DataSedutaGara,TMF.TermineRichiestaQuesiti,
--							TMF.VisualizzaNotifiche,TMF.TipoBando,TMF.EvidenzaPubblica,TMF.ModalitadiPartecipazione,TMF.IdAziendaAti,
--							TMF.ECONOMICA_ENCRYPT,TMF.TECNICA_ENCRYPT,TMF.ProtocolloInformaticoUscita,TMF.DataProtocolloInformaticoUscita,TMF.ListaModelliMicrolotti,
--							TMF.Appalto_verde,
--							TMF.Acquisto_Sociale,
--							CASE WHEN Id IS NULL THEN 0 ELSE Id END AS IDDOCR,
--							CASE WHEN Id IS NULL THEN 0 ELSE 1 END AS Precisazioni,
--							'1' AS Opendettaglio
							

--						FROM 
--								multilinguismo with(nolock) ,
--								folderdocuments with(nolock) ,
--								foldertypes with(nolock) ,
--								document with(nolock) ,
--								msgpermissions with(nolock) ,
--								tab_utenti_messaggi with(nolock) ,
--								--tab_messaggi TM,
--								tab_messaggi_fields TMF with(nolock) ,
--								DOCUMENT_RISULTATODIGARA with(nolock) ,
--								DOCUMENT_RISULTATODIGARA_ROW with(nolock) ,
--								(	
--									SELECT 
--										cast(COUNT(*) AS varchar(10)) AS NumeroQuesiti, b.mfidmsg 

--										FROM 
--											document_chiarimenti with(nolock) , 
--											messagefields a with(nolock) , 
--											messagefields b with(nolock) , 
--											tab_utenti_messaggi c with(nolock) , 
--											tab_messaggi M  with(nolock) ,
--											tab_messaggi_fields MF with(nolock) 
--										WHERE 
--											id_origin = a.mfidmsg AND 
--											a.mfisubtype = 179 AND 
--											a.mffieldname = 'IdDoc' AND 
--											a.mffieldvalue = b.mffieldvalue AND 
--											b.mfisubtype = 180 AND 
--											b.mffieldname = 'IdDoc' AND 
--											c.uminput = 0 AND 
--											c.umstato = 0 AND 
--											c.umidmsg = a.mfidmsg AND 
--											M.idmsg = b.mfidmsg and 
--											M.idmsg=MF.idmsg AND AdvancedState <> '6' 
--										GROUP BY b.mfidmsg
--								) V 
--								right outer join tab_messaggi TM  with(nolock) on V.mfidmsg = TM.idmsg
--						WHERE 
--								ftidpf = fdidpf AND 
--								fdidpfu = mpidpfu AND 
--								fdIdMsg = mpIdMsg AND 
--								umIdMsg = TM.IdMsg AND 
--								TM.IdMsg = TMF.IdMsg AND 
--								fdIdMsg = umIdMsg AND 
--								upper(rtrim(dcmDescription)) = upper(rtrim(idmultilng)) AND 
--								fdIdPf = 36 AND 
--								msgIType = dcmIType AND 
--								msgISubType = dcmISubType AND 
--								ftiddcm = iddcm AND 
--								umIdPfu = - 10 AND 
--								ftdeleted = 0 AND 
--								dcmDeleted = 0 AND 
--								mpidPfu = - 10 AND 
--								AdvancedState <> '6' and
--								-- v.mfidmsg =* TM.idmsg and
--								id = idHeader AND 
--								TM.IdMsg = ID_MSG_BANDO AND 
--								umstato = 0
						
--						UNION ALL

--						SELECT
--							--IdMsg,
--							umIdPfu AS IdPfu,
--							msgIType,
--							msgISubType,
--							--TMF.*,
--							TMF.IdMsg       ,TMF.iType       ,TMF.iSubType       ,TMF.IdDoc       ,TMF.Stato       ,TMF.AdvancedState       ,TMF.PersistenceType       ,TMF.IdMarketPlace
--							,TMF.Name       ,TMF.Protocol       ,TMF.IdMittente       ,TMF.IdDestinatario      ,TMF.[Read]      ,TMF.Data      ,TMF.ReceivedDataMsg      ,TMF.ExpiryDate
--							,TMF.ProtocolloBando      ,TMF.[Object]      ,TMF.Object_Cover1      ,TMF.ProtocolloOfferta      ,TMF.ProceduraGaraTradizionale      ,TMF.tipoappalto
--							,TMF.CriterioAggiudicazioneGara      ,TMF.AuctionState      ,TMF.DataInizioAsta      ,TMF.DataFineAsta      ,TMF.ImportoBaseAsta      ,TMF.ImportoAppalto
--							,TMF.ProceduraGara      ,TMF.ProtocolBG      ,TMF.AggiudicazioneGara      ,TMF.CriterioFormulazioneOfferte      ,TMF.NumProduct_BANDO_rettifiche
--							,TMF.RagSoc      ,TMF.ImportoBaseAsta2 , TMF.CIG,ReceivedOff,ReceivedQuesiti,TMF.TipoProcedura,
--							TMF.NameBG,TMF.TipoAsta,TMF.ReceivedDomanda,TMF.ReceivedIscrizioni,TMF.sysHabilitStartDate,TMF.FaseGara,
--							TMF.DataAperturaOfferte,TMF.DataAperturaDomande,TMF.DataIISeduta,TMF.DataSedutaGara,TMF.TermineRichiestaQuesiti,
--							TMF.VisualizzaNotifiche,TMF.TipoBando,TMF.EvidenzaPubblica,TMF.ModalitadiPartecipazione,TMF.IdAziendaAti,
--							TMF.ECONOMICA_ENCRYPT,TMF.TECNICA_ENCRYPT,TMF.ProtocolloInformaticoUscita,TMF.DataProtocolloInformaticoUscita,TMF.ListaModelliMicrolotti,
--							TMF.Appalto_verde,
--							TMF.Acquisto_Sociale,
--							0 AS IDDOCR,
--							0 AS Precisazioni,
--							'1' AS Opendettaglio

--						FROM 
--								multilinguismo with(nolock) ,
--								folderdocuments with(nolock) ,
--								foldertypes with(nolock) ,
--								document with(nolock) ,
--								msgpermissions with(nolock) ,
--								tab_utenti_messaggi with(nolock) ,
--								--tab_messaggi TM,
--								tab_messaggi_fields TMF with(nolock) ,

--								(
--									SELECT
--										cast(COUNT(*) AS varchar(10)) AS NumeroQuesiti, b.mfidmsg

--										FROM document_chiarimenti with(nolock) ,
--											messagefields a with(nolock) ,
--											messagefields b with(nolock) ,
--											tab_utenti_messaggi c with(nolock) ,
--											tab_messaggi M with(nolock) ,
--											tab_messaggi_fields MF with(nolock) 
--										WHERE 
--											id_origin = a.mfidmsg AND 
--											a.mfisubtype = 179 AND 
--											a.mffieldname = 'IdDoc' AND 
--											a.mffieldvalue = b.mffieldvalue AND 
--											b.mfisubtype = 180 AND 
--											b.mffieldname = 'IdDoc' AND 
--											c.uminput = 0 AND 
--											c.umstato = 0 AND 
--											c.umidmsg = a.mfidmsg AND 
--											M.idmsg = b.mfidmsg AND 
--											M.idmsg = MF.idmsg AND 
--											AdvancedState <> '6'
--										GROUP BY b.mfidmsg
--								) V  
--								right outer join tab_messaggi TM  with(nolock) on V.mfidmsg = TM.idmsg
--						WHERE 
--								ftidpf = fdidpf
--								AND fdidpfu = mpidpfu
--								AND fdIdMsg = mpIdMsg
--								AND umIdMsg = TM.IdMsg
--								AND TM.IdMsg = TMF.IdMsg
--								AND fdIdMsg = umIdMsg
--								AND upper(rtrim(dcmDescription)) = upper(rtrim(idmultilng))
--								AND fdIdPf = 36
--								AND msgIType = dcmIType
--								AND msgISubType = dcmISubType
--								AND ftiddcm = iddcm
--								AND umIdPfu = - 10
--								AND ftdeleted = 0
--								AND dcmDeleted = 0
--								AND mpidPfu = - 10
--								AND  AdvancedState <> '6'
--								--AND v.mfidmsg =* TM.idmsg
--								AND TM.IdMsg NOT IN
--											(
--													SELECT
--													ID_MSG_BANDO
--													FROM DOCUMENT_RISULTATODIGARA  with(nolock) , DOCUMENT_RISULTATODIGARA_ROW with(nolock) 
--													WHERE id = idheader
--											)
--								AND umstato = 0


--						UNION ALL

--						SELECT
							
--							V.*,
--							CASE WHEN Id IS NULL THEN 0 ELSE Id END AS IDDOCR,
--							CASE WHEN Id IS NULL THEN 0 ELSE 1 END AS Precisazioni,
--							'1' AS Opendettaglio

--							FROM 
--								(
--									SELECT  
--										umIdPfu AS IdPfu, msgIType, msgISubType, 
--										--TMF.* 
--										TMF.IdMsg       ,TMF.iType       ,TMF.iSubType       ,TMF.IdDoc       ,TMF.Stato       ,TMF.AdvancedState       ,TMF.PersistenceType       ,TMF.IdMarketPlace
--										,TMF.Name       ,TMF.Protocol       ,TMF.IdMittente       ,TMF.IdDestinatario      ,TMF.[Read]      ,TMF.Data      ,TMF.ReceivedDataMsg      ,TMF.ExpiryDate
--										,TMF.ProtocolloBando      ,TMF.[Object]      ,TMF.Object_Cover1      ,TMF.ProtocolloOfferta      ,TMF.ProceduraGaraTradizionale      ,TMF.tipoappalto
--										,TMF.CriterioAggiudicazioneGara      ,TMF.AuctionState      ,TMF.DataInizioAsta      ,TMF.DataFineAsta      ,TMF.ImportoBaseAsta      ,TMF.ImportoAppalto
--										,TMF.ProceduraGara      ,TMF.ProtocolBG      ,TMF.AggiudicazioneGara      ,TMF.CriterioFormulazioneOfferte      ,TMF.NumProduct_BANDO_rettifiche
--										,TMF.RagSoc      ,TMF.ImportoBaseAsta2 , TMF.CIG,ReceivedOff,ReceivedQuesiti,TMF.TipoProcedura,
--										TMF.NameBG,TMF.TipoAsta,TMF.ReceivedDomanda,TMF.ReceivedIscrizioni,TMF.sysHabilitStartDate,TMF.FaseGara,
--										TMF.DataAperturaOfferte,TMF.DataAperturaDomande,TMF.DataIISeduta,TMF.DataSedutaGara,TMF.TermineRichiestaQuesiti,
--										TMF.VisualizzaNotifiche,TMF.TipoBando,TMF.EvidenzaPubblica,TMF.ModalitadiPartecipazione,TMF.IdAziendaAti,
--										TMF.ECONOMICA_ENCRYPT,TMF.TECNICA_ENCRYPT,TMF.ProtocolloInformaticoUscita,TMF.DataProtocolloInformaticoUscita,TMF.ListaModelliMicrolotti
--										,TMF.Appalto_verde
--										,TMF.Acquisto_Sociale

--									FROM 
--											multilinguismo with(nolock) , 
--											folderdocuments with(nolock) , 
--											foldertypes with(nolock) , 
--											document with(nolock) , 
--											msgpermissions with(nolock) , 
--											tab_utenti_messaggi with(nolock) , 
--											tab_messaggi TM  with(nolock) , 
--											tab_messaggi_fields TMF  with(nolock) 
--									WHERE 
--											ftidpf = fdidpf AND 
--											fdidpfu = mpidpfu AND 
--											fdIdMsg = mpIdMsg AND 
--											umIdMsg = TM.IdMsg AND 
--											TM.IdMsg = TMF.IdMsg AND 
--											fdIdMsg = umIdMsg AND 
--											upper(rtrim(dcmDescription)) = upper(rtrim(idmultilng)) AND 
--											fdIdPf = 15 AND 
--											msgIType = dcmIType AND 
--											msgISubType = dcmISubType AND 
--											ftiddcm = iddcm AND 
--											umIdPfu = - 10 AND 
--											ftdeleted = 0 AND 
--											dcmDeleted = 0 AND 
--											mpidPfu = - 10 
--									UNION ALL 

--									SELECT  
--										umIdPfu AS IdPfu, msgIType, msgISubType, 
		
--									--TMF.*   
--										TMF.IdMsg       ,TMF.iType       ,TMF.iSubType       ,TMF.IdDoc       ,TMF.Stato       ,TMF.AdvancedState       ,TMF.PersistenceType       ,TMF.IdMarketPlace
--										,TMF.Name       ,TMF.Protocol       ,TMF.IdMittente       ,TMF.IdDestinatario      ,TMF.[Read]      ,TMF.Data      ,TMF.ReceivedDataMsg      ,TMF.ExpiryDate
--										,TMF.ProtocolloBando      ,TMF.[Object]    
										
--										,
--										--CASE ADVANCEDSTATE
				
--										--	WHEN '6' then 	'<strong>Bando In Rettifica - </strong> '  + Object_Cover1
--										--	WHEN '7' then 	'<strong>Bando Revocato - </strong> '  + Object_Cover1
--										--		ELSE
--										--	case 
--										--		WHEN NumProduct_PRODUCTS3_rettifiche not in ('','0') then '<strong>Bando Rettificato - </strong> '  + Object_Cover1
--										--	else Object_Cover1
--										--	end
--										--END + '&nbsp;' AS Oggetto
--										TMF.Object_Cover1  AS Oggetto
--										  ,TMF.ProtocolloOfferta      ,TMF.ProceduraGaraTradizionale      ,TMF.tipoappalto
--										,TMF.CriterioAggiudicazioneGara      ,TMF.AuctionState      ,TMF.DataInizioAsta      ,TMF.DataFineAsta      ,TMF.ImportoBaseAsta2 as ImportoBaseAsta      ,TMF.ImportoBaseAsta2 as ImportoAppalto
--										,TMF.ProceduraGara      ,TMF.ProtocolBG      ,TMF.AggiudicazioneGara      ,TMF.CriterioFormulazioneOfferte      ,TMF.NumProduct_BANDO_rettifiche
--										,TMF.RagSoc      ,TMF.ImportoBaseAsta2 , TMF.CIG,ReceivedOff,ReceivedQuesiti,TMF.TipoProcedura,
--										TMF.NameBG,TMF.TipoAsta,TMF.ReceivedDomanda,TMF.ReceivedIscrizioni,TMF.sysHabilitStartDate,TMF.FaseGara,
--										TMF.DataAperturaOfferte,TMF.DataAperturaDomande,TMF.DataIISeduta,TMF.DataSedutaGara,TMF.TermineRichiestaQuesiti,
--										TMF.VisualizzaNotifiche,TMF.TipoBando,TMF.EvidenzaPubblica,TMF.ModalitadiPartecipazione,TMF.IdAziendaAti,
--										TMF.ECONOMICA_ENCRYPT,TMF.TECNICA_ENCRYPT,TMF.ProtocolloInformaticoUscita,TMF.DataProtocolloInformaticoUscita,TMF.ListaModelliMicrolotti
--										,TMF.Appalto_verde
--										,TMF.Acquisto_Sociale
--									FROM
--											tab_utenti_messaggi with(nolock) , 
--											tab_messaggi TM  with(nolock) , 
--											tab_messaggi_fields TMF   with(nolock) 
--									WHERE 
--											umIdMsg = TM.IdMsg AND 
--											TM.IdMsg = TMF.IdMsg AND 
--											msgIType = 55 AND 
--											msgISubType = 48 AND 
--											uminput = 0 AND 
--											umstato = 0 AND 
--											Stato = '2' 
											
--									UNION ALL 
			
--									SELECT 
--										umIdPfu AS IdPfu, 
--										msgIType, msgISubType, 
--										--TMF.* 
--										TMF.IdMsg       ,TMF.iType       ,TMF.iSubType       ,TMF.IdDoc       ,TMF.Stato       ,TMF.AdvancedState       ,TMF.PersistenceType       ,TMF.IdMarketPlace
--										,TMF.Name       ,TMF.Protocol       ,TMF.IdMittente       ,TMF.IdDestinatario      ,TMF.[Read]      ,TMF.Data      ,TMF.ReceivedDataMsg      ,TMF.ExpiryDate
--										,TMF.ProtocolloBando      ,TMF.[Object]      ,TMF.Object_Cover1      ,TMF.ProtocolloOfferta      ,TMF.ProceduraGaraTradizionale      ,TMF.tipoappalto
--										,TMF.CriterioAggiudicazioneGara      ,TMF.AuctionState      ,TMF.DataInizioAsta      ,TMF.DataFineAsta      ,TMF.ImportoBaseAsta      ,TMF.ImportoAppalto
--										,TMF.ProceduraGara      ,TMF.ProtocolBG      ,TMF.AggiudicazioneGara      ,TMF.CriterioFormulazioneOfferte      ,TMF.NumProduct_BANDO_rettifiche
--										,TMF.RagSoc      ,TMF.ImportoBaseAsta2 , TMF.CIG,ReceivedOff,ReceivedQuesiti,TMF.TipoProcedura,
--										TMF.NameBG,TMF.TipoAsta,TMF.ReceivedDomanda,TMF.ReceivedIscrizioni,TMF.sysHabilitStartDate,TMF.FaseGara,
--										TMF.DataAperturaOfferte,TMF.DataAperturaDomande,TMF.DataIISeduta,TMF.DataSedutaGara,TMF.TermineRichiestaQuesiti,
--										TMF.VisualizzaNotifiche,TMF.TipoBando,TMF.EvidenzaPubblica,TMF.ModalitadiPartecipazione,TMF.IdAziendaAti,
--										TMF.ECONOMICA_ENCRYPT,TMF.TECNICA_ENCRYPT,TMF.ProtocolloInformaticoUscita,TMF.DataProtocolloInformaticoUscita,TMF.ListaModelliMicrolotti
--										,TMF.Appalto_verde
--										,TMF.Acquisto_Sociale
--									FROM 
--											tab_utenti_messaggi with(nolock) , 
--											tab_messaggi TM  with(nolock) , 
--											tab_messaggi_fields TMF  with(nolock) 
--									WHERE 
--											umIdMsg = TM.IdMsg AND 
--											TM.IdMsg = TMF.IdMsg AND 
--											msgIType = 55 AND 
--											msgISubType = 78 AND 
--											uminput = 0 AND 
--											umstato = 0 AND 
--											Stato = '2' AND 
--											AuctionState <> '3' 
						
--									UNION ALL 
			
--									SELECT  
--										umIdPfu AS IdPfu, msgIType, msgISubType, 
--										--TMF.* 
--										TMF.IdMsg       ,TMF.iType       ,TMF.iSubType       ,TMF.IdDoc       ,TMF.Stato       ,TMF.AdvancedState       ,TMF.PersistenceType       ,TMF.IdMarketPlace
--										,TMF.Name       ,TMF.Protocol       ,TMF.IdMittente       ,TMF.IdDestinatario      ,TMF.[Read]      ,TMF.Data      ,TMF.ReceivedDataMsg      ,TMF.ExpiryDate
--										,TMF.ProtocolloBando      ,TMF.[Object]      ,TMF.Object_Cover1      ,TMF.ProtocolloOfferta      ,TMF.ProceduraGaraTradizionale      ,TMF.tipoappalto
--										,TMF.CriterioAggiudicazioneGara      ,TMF.AuctionState      ,TMF.DataInizioAsta      ,TMF.DataFineAsta      ,TMF.ImportoBaseAsta      ,TMF.ImportoAppalto
--										,TMF.ProceduraGara      ,TMF.ProtocolBG      ,TMF.AggiudicazioneGara      ,TMF.CriterioFormulazioneOfferte      ,TMF.NumProduct_BANDO_rettifiche
--										,TMF.RagSoc      ,TMF.ImportoBaseAsta2 , TMF.CIG,ReceivedOff,ReceivedQuesiti,TMF.TipoProcedura,
--										TMF.NameBG,TMF.TipoAsta,TMF.ReceivedDomanda,TMF.ReceivedIscrizioni,TMF.sysHabilitStartDate,TMF.FaseGara,
--										TMF.DataAperturaOfferte,TMF.DataAperturaDomande,TMF.DataIISeduta,TMF.DataSedutaGara,TMF.TermineRichiestaQuesiti,
--										TMF.VisualizzaNotifiche,TMF.TipoBando,TMF.EvidenzaPubblica,TMF.ModalitadiPartecipazione,TMF.IdAziendaAti,
--										TMF.ECONOMICA_ENCRYPT,TMF.TECNICA_ENCRYPT,TMF.ProtocolloInformaticoUscita,TMF.DataProtocolloInformaticoUscita,TMF.ListaModelliMicrolotti
--										,TMF.Appalto_verde
--										,TMF.Acquisto_Sociale
--									FROM 
--											tab_utenti_messaggi with(nolock) , 
--											tab_messaggi TM  with(nolock) , 
--											tab_messaggi_fields TMF   with(nolock) 
--									WHERE 
--											umIdMsg = TM.IdMsg AND 
--											TM.IdMsg = TMF.IdMsg AND 
--											umIdPfu=-10 AND 
--											msgIType = 55 AND 
--											msgISubType = 168 and 
--											umstato = 0 and
--											(EvidenzaPubblica=1 or EvidenzaPubblica IS NULL) and
--											TMF.iddoc not in (select JumpCheck from CTL_DOC with(nolock)  where TipoDoc='BANDO_NON_VIS' and Deleted=0) 
--								) V 
--								left outer join DOCUMENT_RISULTATODIGARA	 with(nolock) 	--WHERE V.IdMsg *= ID_MSG_BANDO
--								on V.IdMsg = ID_MSG_BANDO AND 
--									id IN  (
--												SELECT idheader 
--												FROM DOCUMENT_RISULTATODIGARA_ROW  with(nolock) 
--											)
--							) a
--							--left outer join profiliutente u with(nolock) on idMittente =  u.idpfu
--						WHERE 
--							TipoAppalto = DOMTipologia.DMV_CodExt AND 
--							CriterioAggiudicazioneGara = DOMCriterio.DMV_CodExt

--					UNION ALL

--					SELECT 
--						M.IdMsg
--						, umIdPfu AS IdPfu
--						, msgIType
--						, msgISubType

--						,CASE WHEN Id IS NULL THEN 0 
--							ELSE Id 
--							END AS IDDOCR 

--						,CASE WHEN Id IS NULL THEN 0 
--							ELSE 1 
--							END AS Precisazioni
--						,'1' AS Opendettaglio
--						, Name
--						,TMF.IdDoc
--						, TMF.ProtocolloBando
--						, TMF.CIG
--						, ProtocolloOfferta
--						, ReceivedDataMsg

----						, CASE NumProduct_BANDO_rettifiche
----							WHEN '' THEN Object_Cover1
----							WHEN '0' THEN Object_Cover1
----							ELSE  '<strong>Bando Rettificato - </strong> '  + Object_Cover1
----							END + '&nbsp;' AS Oggetto
--						,CASE ADVANCEDSTATE
				
--							WHEN '6' then 	'<strong>Bando In Rettifica - </strong> '  + Object_Cover1
--							WHEN '7' then 	'<strong>Bando Revocato - </strong> '  + Object_Cover1
--							ELSE
--								case 
--									WHEN NumProduct_BANDO_rettifiche not in ('','0') then '<strong>Bando Rettificato - </strong> '  + Object_Cover1
--									else Object_Cover1
--								end
			
--						END + '&nbsp;' AS Oggetto

--						, CAST(DOMTipologia.DMV_COD AS VARCHAR) AS Tipologia

--						,TMF.ExpiryDate
--						,TMF.ExpiryDate as expirydateAl

--						, ImportoBaseAsta
						
--						, CASE ProceduraGara
--									WHEN '' THEN ''
--									ELSE dbo.GetCodFromCodExt('TipoProcedura',ProceduraGara )
--						  END AS tipoprocedura

--						, Stato AS StatoGD
						
--						, DOMCriterio.DMV_COD AS CriterioAggiudicazione 
						
--						,RagSoc AS EnteAppaltante
--						,Appalto_verde
--						,Acquisto_Sociale
						
--						,TipoBando as TipoBandoGara
--						,idMittente

--					FROM 
--							(
--								SELECT 
--									DMV_Cod
--									, DMV_CodExt
--									FROM LIB_DomainValues
--									WHERE DMV_DM_Id = 'Tipologia'
--								UNION
--								SELECT DMV_Cod
--									, DMV_Cod AS DMV_CodExt
--									FROM LIB_DomainValues
--									WHERE DMV_DM_Id = 'Tipologia'     
--							) AS DOMTipologia,

--							(
--								SELECT '' AS DMV_Cod
--									, '' AS DMV_CodExt
--								UNION
--								SELECT DMV_Cod
--									, DMV_CodExt
--									FROM LIB_DomainValues
--									WHERE DMV_DM_Id = 'Criterio'
--								UNION
--								SELECT DMV_Cod
--									, DMV_Cod AS DMV_CodExt
--									FROM LIB_DomainValues
--									WHERE DMV_DM_Id = 'Criterio'
--							) AS DOMCriterio, 

--							(
--								SELECT '' AS DMV_Cod
--									, '' AS DMV_CodExt
--								UNION
--								SELECT DMV_Cod
--									, DMV_CodExt
--									FROM LIB_DomainValues
--									WHERE DMV_DM_Id = 'TipoProcedura'
--										AND DMV_CodExt <> ''
--										AND DMV_CodExt IS NOT NULL
--								UNION
--								SELECT DMV_Cod
--									, DMV_Cod AS DMV_CodExt
--									FROM LIB_DomainValues
--									WHERE DMV_DM_Id = 'TipoProcedura'
--										AND DMV_CodExt <> ''
--										AND DMV_CodExt IS NOT NULL
--							) AS DOMTipoProcedura, 

--							multilinguismo with(nolock) , 
--							document with(nolock) ,  
--							tab_utenti_messaggi tu with(nolock) , 
--							tab_messaggi M with(nolock) ,

--							(
--								select distinct id , mfFieldValue as IdDoc 
--									from 
--										DOCUMENT_RISULTATODIGARA with(nolock) ,
--										DOCUMENT_RISULTATODIGARA_ROW with(nolock) ,
--										messagefields  with(nolock) 
--									where 
--										idheader=id and 
--										mfidmsg=id_msg_bando  and 
--										mfFieldName='IdDoc'
--							) V 
--							right outer join messagefields mf  with(nolock) on v.iddoc = mf.mffieldvalue,
--							tab_messaggi_fields TMF  with(nolock) 
--							left outer join 
--							(
--								select distinct protocollobando ,storico ,statoprogetto 
--									from  document_progetti with(nolock) 
--							) DP   on TMF.protocollobando = DP.protocollobando and 
--										DP.storico=0 and DP.statoprogetto='garaconclusa'			
--					WHERE       
--							TipoAppalto = DOMTipologia.DMV_CODEXT AND 
--							AggiudicazioneGara = DOMCriterio.DMV_CODEXT AND 
--							ProceduraGara = DOMTipoProcedura.DMV_CODEXT AND 
--							umIdMsg = M.IdMsg and 
--							upper(rtrim(dcmDescription)) = upper(rtrim(idmultilng)) and 
--							msgIType = dcmIType and 
--							msgISubType = dcmISubType and 
--							dcmDeleted = 0 and 
--							msgISubType in (167) and 
--							msgIType = 55 and 
--							M.IdMsg = TMF.Idmsg and 
--							uminput=0 and 
--							umstato=0 and 
--							umidpfu > 0 and 
--							M.idmsg=mfidmsg and 
--							mffieldname='IdDoc' and 
--							TMF.TipoBando='3' AND 
--							TMF.AdvancedState <> '6' and 
--							TMF.iddoc not in (select JumpCheck from CTL_DOC where TipoDoc='BANDO_NON_VIS' and Deleted=0) and
--							TMF.Stato=2
					
--				) V


--				left outer join (
--					select distinct protocollobando ,storico ,statoprogetto 
--						from  document_progetti with(nolock) 
--				) DP   on v.protocollobando = DP.protocollobando and 
--							DP.storico=0 and DP.statoprogetto='garaconclusa'			
--				left outer join tab_messaggi_fields TMF with(nolock)  on tmf.idmsg = v.IdMsg
--				left outer join profiliutente u with(nolock) on v.idMittente =  u.idpfu
--			where V.ProtocolloBando not like 'Demo%'
--				and isnull( EvidenzaPubblica , '1' ) <> '0'


--		union all

		

		-- si aggiungono i bandi semplificati
		select 
			id as IdMsg, 
			ctl_doc.IdPfu, 
			1000 as msgIType, 
			case 
				when tipodoc = 'BANDO_SEMPLIFICATO' then 221 
				else 0 
				end as msgISubType, 
			0 as IDDOCR, 
			--0 as Precisazioni,
			CASE WHEN Dr.leg IS NULL THEN 0 
			   ELSE 1 
			END AS Precisazioni,
			'1' as OpenDettaglio ,
			Titolo as Name,
			cast( GUID as  varchar(100) )  as IdDoc, 

			ProtocolloBando,
			CIG, 
			isnull(ctl_doc.Protocollo ,'') as ProtocolloOfferta, 
			DataInvio as ReceivedDataMsg, 
			case
				 when ctl_doc.statofunzionale = 'revocato' then '<strong>Bando Revocato - </strong> ' + cast(Body as nvarchar (2000)) 				
				 when ctl_doc.statofunzionale = 'InRettifica' then '<strong>Bando In Rettifica - </strong> ' + cast(Body as nvarchar (2000)) 
				 when ctl_doc.statofunzionale = 'Sospeso' then '<strong>Procedura Sospesa - </strong> ' + cast(Body as nvarchar (2000)) 
				 when ctl_doc.statofunzionale = 'InSospensione' then '<strong>Procedura in Sospensione - </strong> ' + cast(Body as nvarchar (2000)) 
			else
				case 
					when isnull(v.linkeddoc,0) > 0 and V.TipoModifica =  'RIPRISTINO_GARA' then '<strong>Procedura Ripristinata - </strong> ' + cast( Body as nvarchar(4000)) 
					when isnull(v.linkeddoc,0) > 0 and V.TipoModifica <> 'RIPRISTINO_GARA' then  '<strong>Bando Rettificato - </strong> ' + cast( Body as nvarchar(4000)) 
				else
					cast( Body as nvarchar(4000)) 
				end				
			end as Oggetto,		


			TipoAppaltoGara as Tipologia, 
			convert( varchar(19),isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa),120) as ExpiryDate, 
			convert( varchar(19),isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa),120) as ExpiryDateAl, 

			replace(str(ImportoBaseAsta, 25, 2),',','.') AS ImportoBaseAsta,
			
			ProceduraGara as tipoprocedura, 
			case statodoc 
				when 'Sended' then '2' 
				else '1' 
			end as StatoGD, 
			case CriterioAggiudicazioneGara 
				when 15531 then 1
				when 15532 then 2
				when 16291 then 3
				when 25532 then 4
				end as CriterioAggiudicazione, 
			
			aziRagioneSociale as EnteAppaltante,
			
			ISNULL(Appalto_Verde,'no') as Appalto_Verde,
			ISNULL(Acquisto_Sociale,'no') as Acquisto_Sociale ,
			
			TipoBandoGara ,
			ctl_doc.idpfu as IdMittente ,
			a.idAzi as AZI_Ente,

			--0 as  Scaduto, 
			case when isnull( DataScadenzaOfferta ,DataScadenzaOffIndicativa) > getdate() then '0' else '1' end as Scaduto, 
			'1' as EvidenzaPubblica
			,tipodoc as DOCUMENT 
			,tipodoc as OPEN_DOC_NAME 
			,case 
					when Appalto_Verde='si' and Acquisto_Sociale='si' then '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">&nbsp;<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">'  
					when Appalto_Verde='si' and Acquisto_Sociale='no' then  '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">' 
					when Appalto_Verde='no' and Acquisto_Sociale='si' then  '<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">' 
			end as Bando_Verde_Sociale,
			Protocollo,
			case when TipoSedutaGara='virtuale' then case when StatoSeduta is null then 'prevista' else case when StatoSeduta='aperta' then 'incorso' else 'prevista' end  end else '' end as SedutaVirtuale
			,EnteProponente 
		from ctl_doc  with(nolock) 
			inner join aziende a with(nolock) on azienda = a.idazi
			inner join document_bando  with(nolock)  on id = idheader
			left  join (
			
			
					select d.linkedDoc , TipoDoc as TipoModifica  from ctl_doc d with(nolock) 
						inner join ( 
										Select max(id) as ID_DOC ,  linkedDoc from ctl_doc  with(nolock) where tipodoc IN ('RETTIFICA_BANDO','PROROGA_BANDO','RETTIFICA_GARA','PROROGA_GARA'  , 'RIPRISTINO_GARA'  ) and Statodoc ='Sended' group by linkedDoc  
										) as M on M.id_DOC = d.id
			
					) V on V.LinkedDoc=CTL_DOC.id
			left outer join
			(
				select distinct leg
					from
						DOCUMENT_RISULTATODIGARA_ROW_VIEW
					where StatoFunzionale='Inviato'						
			) DR on DR.leg=ctl_doc.id 
		where tipodoc in ( 'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and ctl_doc.statofunzionale not in ('InLavorazione' , 'InApprove' , 'Rifiutato') and ctl_doc.deleted = 0 and evidenzapubblica = '1'

		






GO
