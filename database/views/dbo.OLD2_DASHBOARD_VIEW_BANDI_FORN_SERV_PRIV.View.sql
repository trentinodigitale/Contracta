USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV]  AS
--Versione=5&data=2013-10-29&Attivita=47938&Nominativo=Enrico
-- ragionamento sulle risposte in base a iddoc del documento origine
--Versione=6&data=2014-02-20&Attivita=47938&Nominativo=Enrico
-- ragionamento bando revocato
--Versione=7&data=2014-02-24&Attivita=53377&Nominativo=Enrico
--Versione=8&data=2014-03-10&Attivita=54302&Nominativo=Enrico
--Versione=9&data=2014-04-24&Attivita=54963&Nominativo=Enrico
--Versione=10&data=2015-01-22&Attivita=68354&Nominativo=Sabato
--Versione=11&data=2020-04-07&Attivita=296784&Nominativo=Francesco
														   
--select 
--	IdMsg, a.IdPfu, msgIType, msgISubType, IDDOCR, Precisazioni, Name, bRead, ProtocolloBando, 
--	ProtocolloOfferta, ReceivedDataMsg, Oggetto, Tipologia, expirydate, ImportoBaseAsta, tipoprocedura, 
--	StatoGD, a.Fascicolo, CriterioAggiudicazione, CriterioFormulazioneOfferta, OpenDettaglio, Scaduto, 
--	IdDoc, TipoBando, CIG, isnull(OpenOfferte,'') as StatoCollegati , OPEN_DOC_NAME,isnull(OpenOfferte,'') as OpenOfferte,EnteAppaltante
--	,   Protocollo ,'' as TipoProceduraCaratteristica,
--	 a.Appalto_verde, a.Acquisto_Sociale,
--	 case 
--					when a.Appalto_Verde='si' and a.Acquisto_Sociale='si' then '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">&nbsp;<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">'  
--					when a.Appalto_Verde='si' and a.Acquisto_Sociale='no' then  '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">' 
--					when a.Appalto_Verde='no' and a.Acquisto_Sociale='si' then  '<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">' 
--		end as Bando_Verde_Sociale

--	, p.pfuIdAzi as AZI_Ente
--	,'' as SedutaVirtuale
--	,'' as EnteProponente 
--from 
--	(
 
--		SELECT 
--			M.IdMsg
--			, umIdPfu AS IdPfu
--			, msgIType
--			, msgISubType

--			,CASE WHEN Id IS NULL THEN 0 
--				ELSE Id 
--			END AS IDDOCR 

--			,CASE WHEN Id IS NULL THEN 0 
--			   ELSE 1 
--			END AS Precisazioni

--			, Name
--			, [read] as  bRead
--			, TMF.ProtocolloBando
--			--, TMF.TipoBando
--			, ProtocolloOfferta
--			, ReceivedDataMsg

--			, 
----			 CASE 
----				
----				WHEN NumProduct_BANDO_rettifiche in ('','0') then
----						case advancedstate		
----							when '6' then 	'<strong>Bando In Rettifica - </strong> '  + Object_Cover1
----							else Object_Cover1
----						end 
----
----				ELSE  '<strong>Bando Rettificato - </strong> '  + Object_Cover1
----
----			  END + '&nbsp;' AS Oggetto

--			CASE ADVANCEDSTATE
				
--				WHEN '6' then 	'<strong>Bando In Rettifica - </strong> '  + Object_Cover1
--				WHEN '7' then 	'<strong>Bando Revocato - </strong> '  + Object_Cover1
				
--				ELSE
--					case 
--						WHEN msgISubType = '49' and NumProduct_PRODUCTS3_rettifiche not in ('','0') then '<strong>Bando Rettificato - </strong> '  + Object_Cover1
--						WHEN NumProduct_BANDO_rettifiche not in ('','0') then '<strong>Bando Rettificato - </strong> '  + Object_Cover1
--						else Object_Cover1
--					end
			
--			END + '&nbsp;' AS Oggetto

--			, CASE tipoappalto
--				WHEN '' THEN ''
--				ELSE dbo.GetCodFromCodExt('Tipologia',tipoappalto )
--			END AS Tipologia

--			, CASE ExpiryDate
--				WHEN '' THEN ''
--				ELSE 
--					case msgISubType	
--						when '79' then DataFineAsta
--						when '113' then DataFineAsta
--						when '153' then DataFineAsta
--						else ExpiryDate
--					end 
--			END AS expirydate

--			, case msgISubType	
--						when '21' then ImportoAppalto
--						when '79' then ImportoAppalto
--						when '113' then ImportoAppalto
--						when '153' then ImportoAppalto
--						when '69' then ImportoBaseAsta2
--						else ImportoBaseAsta
--			  END AS ImportoBaseAsta

--			, CASE ProceduraGara
--						WHEN '' THEN ''
--						ELSE dbo.GetCodFromCodExt('TipoProcedura',ProceduraGara )
--			  END AS tipoprocedura

--			, Stato AS StatoGD
--			, ProtocolBG as Fascicolo

--			, CASE AggiudicazioneGara
--					WHEN '' THEN ''
--					ELSE dbo.GetCodFromCodExt('Criterio',AggiudicazioneGara )
--			   END AS CriterioAggiudicazione

--			, CASE CriterioFormulazioneOfferte
--					WHEN '' THEN ''
--					ELSE dbo.GetCodFromCodExt('CriterioOfferte',CriterioFormulazioneOfferte )
--			  END AS CriterioFormulazioneOfferta

--			, '1' as OpenDettaglio

----			, CASE 
----				WHEN DP.protocollobando is null THEN '0'
----				ELSE '1'
----			  END AS Scaduto

--			,CASE WHEN TMF.iSubType	in ('79','113', '153' ) THEN

--					--per le aste
--					CASE WHEN TMF.DataFineAsta < CONVERT(VARCHAR(50), GETDATE(), 126) 
--						THEN 1 
--						ELSE 0 
--					END 

--				  ELSE		
					
--					CASE WHEN TMF.ExpiryDate < CONVERT(VARCHAR(50), GETDATE(), 126) 
--						THEN 1 
--						ELSE 0 
--					END 

--			END as Scaduto

--			, TMF.IdDoc
--			, TMF.TipoBando
--			, TMF.CIG
--			, '' as OPEN_DOC_NAME
--			,RagSoc AS EnteAppaltante 
--			, Protocol as Protocollo

--			,Appalto_verde
--			,Acquisto_Sociale
--			,IdMittente
   
--		FROM 

--			multilinguismo with(nolock) , 
--			document with(nolock) ,  
--			tab_utenti_messaggi tu with(nolock) , 
--			tab_messaggi M with(nolock) ,
   
--			(
															   
		
									   
																															  
																				  
																																	  
		   
																  
		
		
	
	   
	
--				select distinct id , mfFieldValue as IdDoc 
--					from 
--						DOCUMENT_RISULTATODIGARA with(nolock) ,
--						DOCUMENT_RISULTATODIGARA_ROW with(nolock) ,
--						messagefields with(nolock) 
--					where 
--						idheader=id and 
--						mfidmsg=id_msg_bando  and 
--						mfFieldName='IdDoc'
									
						
--			) V 
--			right outer join messagefields mf  with(nolock) on v.iddoc = mf.mffieldvalue,
--			tab_messaggi_fields TMF  with(nolock) 
----			left outer join ( 
----				select distinct protocollobando ,storico ,statoprogetto 
----					from  document_progetti
----			) DP   on TMF.protocollobando = DP.protocollobando and 
----						DP.storico=0 and 
----						DP.statoprogetto='garaconclusa'			
--		WHERE  umIdMsg = M.IdMsg  
--				and upper(rtrim(dcmDescription)) = upper(rtrim(idmultilng))  
--				and msgIType = dcmIType  
--				and msgISubType = dcmISubType  
--				and dcmDeleted = 0  
--				and msgISubType in ( 25 ,21 ,37 , 49, 79,153 , 113,64,69,75)
--				and msgIType = 55
--				and M.IdMsg = TMF.Idmsg
--				and uminput=0
--				and umstato=0
--				and umidpfu > 0
--				and M.idmsg=mfidmsg
--				and mffieldname='IdDoc'
		

--	UNION ALL
		
		
--		SELECT 
--			M.IdMsg
--			, umIdPfu AS IdPfu
--			, msgIType
--			, msgISubType

--			,CASE WHEN Id IS NULL THEN 0 
--				ELSE Id 
--			END AS IDDOCR 

--			,CASE WHEN Id IS NULL THEN 0 
--			   ELSE 1 
--			END AS Precisazioni

--			, Name
--			, [read] as  bRead
--			, TMF.ProtocolloBando
--			--, TMF.TipoBando
--			, ProtocolloOfferta
--			, ReceivedDataMsg

--			,CASE ADVANCEDSTATE
				
--				WHEN '6' then 	'<strong>Bando In Rettifica - </strong> '  + Object_Cover1
--				WHEN '7' then 	'<strong>Bando Revocato - </strong> '  + Object_Cover1

--				ELSE
--					case 
--						WHEN NumProduct_BANDO_rettifiche not in ('','0') then '<strong>Bando Rettificato - </strong> '  + Object_Cover1
--						else Object_Cover1
--					end
			
--			END + '&nbsp;' AS Oggetto

--			, CASE tipoappalto
--				WHEN '' THEN ''
--				ELSE dbo.GetCodFromCodExt('Tipologia',tipoappalto )
--			END AS Tipologia

--			, ExpiryDate
				

--			, ImportoBaseAsta
			  
--			, CASE ProceduraGara
--						WHEN '' THEN ''
--						ELSE dbo.GetCodFromCodExt('TipoProcedura',ProceduraGara )
--			  END AS tipoprocedura

--			, Stato AS StatoGD
--			, ProtocolBG as Fascicolo

--			, CASE AggiudicazioneGara
--					WHEN '' THEN ''
--					ELSE dbo.GetCodFromCodExt('Criterio',AggiudicazioneGara )
--			   END AS CriterioAggiudicazione

--			, CASE CriterioFormulazioneOfferte
--					WHEN '' THEN ''
--					ELSE dbo.GetCodFromCodExt('CriterioOfferte',CriterioFormulazioneOfferte )
--			  END AS CriterioFormulazioneOfferta

--			, '1' as OpenDettaglio

----			, CASE 
----				WHEN DP.protocollobando is null THEN '0'
----				ELSE '1'
----			  END AS Scaduto
			
--			,CASE WHEN TMF.ExpiryDate < CONVERT(VARCHAR(50), GETDATE(), 126) 
--				THEN 1 
--				ELSE 0 
--			END AS Scaduto

--			, TMF.IdDoc
--			, TMF.TipoBando
--			, TMF.CIG
--			, '' as OPEN_DOC_NAME
--			,RagSoc AS EnteAppaltante 
--			, Protocol as Protocollo
--			,Appalto_verde
--			,Acquisto_Sociale
--			,IdMittente
--		FROM 
--			multilinguismo with(nolock) , 
--			document with(nolock) ,  
--			tab_utenti_messaggi tu with(nolock) , 
--			tab_messaggi M with(nolock) ,
--			(
--				select distinct id , mfFieldValue as IdDoc 
--					from 
--						DOCUMENT_RISULTATODIGARA with(nolock) ,
--						DOCUMENT_RISULTATODIGARA_ROW with(nolock) ,
--						messagefields  with(nolock) 
--					where 
--						idheader=id and 
--						mfidmsg=id_msg_bando  and 
--						mfFieldName='IdDoc'
						
--			) V 
																		 
	
																 
		  
										  
																																  
																					 
																																		  
			  
																	   
		
		
--			right outer join messagefields mf  with(nolock) on v.iddoc = mf.mffieldvalue,
--			tab_messaggi_fields TMF  with(nolock) 
--			left outer join (
--				select distinct protocollobando ,storico ,statoprogetto 
--				from  document_progetti with(nolock) 
--			) DP   on	
--					TMF.protocollobando = DP.protocollobando and 
--					DP.storico=0 and 
--					DP.statoprogetto='garaconclusa'			
--		WHERE  
--			umIdMsg = M.IdMsg  
--			and upper(rtrim(dcmDescription)) = upper(rtrim(idmultilng))  
--			and msgIType = dcmIType  
--			and msgISubType = dcmISubType  
--			and dcmDeleted = 0  
--			and msgISubType in (168)
--			and msgIType = 55
--			and M.IdMsg = TMF.Idmsg
--			and uminput=0
--			and umstato=0
--			and umidpfu > 0
--			and M.idmsg=mfidmsg
--			and mffieldname='IdDoc'
--			and  
--			(
--				(ProceduraGara=15476 and TipoBando=2 ) 
--				or
--				(ProceduraGara=15477 and TipoBando=2 )
--				or
--				(
--					( ProceduraGara=15475 or ProceduraGara=15478) 
--					and 
--					TipoBando=1
--				)
--				or
--				(ProceduraGara=15477 and TipoBando=3 ) 
--				or
--				(
--					(ProceduraGara=15475 or ProceduraGara=15478) 
--					and 
--					TipoBando=3
--				)

--			 )




--		) as a 
--	--commentata per il KPF 43317
--	--left outer join MSG_LINKED_STATO_RISPOSTA r on  a.Fascicolo =r.Fascicolo and r.IdPfu = a.IdPfu
--	--left outer join MSG_LINKED_STATO_RISPOSTA_ADVANCED r1 on  a.Fascicolo =r1.Fascicolo and r1.IdPfu = a.IdPfu
--	left outer join MSG_LINKED_STATO_RISPOSTA_ADVANCED r1  with(nolock) on  a.IdDoc =r1.IdDocSource and r1.IdPfu = a.IdPfu
--	left outer join profiliutente p with(nolock) on  p.idpfu = IdMittente

--	union all 


		-- si aggiungono i bandi semplificati
		select 
			d.id as IdMsg, 
			p.IdPfu, 
			1000 as msgIType, 
			case 
				when tipodoc = 'BANDO_SEMPLIFICATO' then 222 
				when tipodoc = 'BANDO_GARA' then 168
				when tipodoc = 'BANDO_ASTA' then 386
				else 0 
				end as msgISubType, 
			
			CASE WHEN DR.leg IS NULL THEN 0 
				ELSE DR.leg 
			END AS IDDOCR ,

			CASE WHEN Dr.leg IS NULL THEN 0 
			   ELSE 1 
			END AS Precisazioni,

			Titolo as Name,
			case when isnull( r.id , 0 ) = 0 then 1 else 0 end as  bRead, 
			ProtocolloBando, 
			Protocollo as ProtocolloOfferta, 
			DataInvio as ReceivedDataMsg, 
			case d.StatoFunzionale
				when 'Revocato' then '<strong>Bando Revocato - </strong> ' + cast( Body as nvarchar(4000)) 
				when 'InRettifica' then '<strong>Bando In Rettifica - </strong> ' + cast( Body as nvarchar(4000)) 
				when  'Sospeso' then '<strong>Procedura Sospesa - </strong> ' + cast(Body as nvarchar (4000)) 
				when  'InSospensione' then '<strong>Procedura in Sospensione - </strong> ' + cast(Body as nvarchar (4000)) 
			else				
				case 
					when isnull(v.linkeddoc,0) > 0 and V.TipoModifica =  'RIPRISTINO_GARA' then '<strong>Procedura Ripristinata - </strong> ' + cast( Body as nvarchar(4000)) 
					when isnull(v.linkeddoc,0) > 0 and V.TipoModifica <> 'RIPRISTINO_GARA' then  '<strong>Bando Rettificato - </strong> ' + cast( Body as nvarchar(4000)) 
				else
					cast( Body as nvarchar(4000)) 
				end				
			end as Oggetto, 

			TipoAppaltoGara as Tipologia, 
			convert( varchar(30) , DataScadenzaOfferta ,126 ) as expirydate, 

			ImportoBaseAsta, 

			ProceduraGara as tipoprocedura, 
			statodoc as StatoGD, 
			Fascicolo, 
			case CriterioAggiudicazioneGara 
				when 15531 then 1
				when 15532 then 2
				when 16291 then 3
				when 25532 then 4
				end as CriterioAggiudicazione, 
			case CriterioFormulazioneOfferte 
				when 15536 then 1 
				when 15537 then 2
				else 0 
				end as CriterioFormulazioneOfferta, 
			'1' as OpenDettaglio ,
			--'0' as Scaduto, -- da capire quando scade
			case when DataScadenzaOfferta > getdate() then '0' else '1' end as Scaduto,
			cast( GUID as varchar (50) ) as IdDoc, 
			TipoBandoGara as TipoBando, 
			CIG,
			case ld.statofunzionale
				when 'InLavorazione' then 'Saved'
				when 'Sended' then 'Sended'
				when 'Inviato' then 'Sended'
				when 'Annullato' then 'Annullata'
				when 'Ritirata' then 'Ritirata'				   
				else ''
			end as StatoCollegati,
			case tipoDoc 
				when 'BANDO_SEMPLIFICATO' then 'BANDO_SEMPLIFICATO_INVITO' 
				else tipoDoc
			end as OPEN_DOC_NAME
			,
			case ld.statofunzionale
				when 'InLavorazione' then 'Saved'
				when 'Sended' then 'Sended'
				when 'Inviato' then 'Sended'
				when 'Annullato' then 'Annullata'
				when 'InAttesaFirma' then 'InAttesaFirma'
				when 'Ritirata' then 'Ritirata'
				else ''
			end as OpenOfferte
			,az.AziRagioneSociale AS EnteAppaltante 
			, d.Protocollo
			, isnull( TipoProceduraCaratteristica , '' ) as TipoProceduraCaratteristica
			,ISNULL(Appalto_Verde,'no') as Appalto_Verde
			,ISNULL(Acquisto_Sociale,'no') as Acquisto_Sociale 
			,case 
					when Appalto_Verde='si' and Acquisto_Sociale='si' then '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">&nbsp;<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">'  
					when Appalto_Verde='si' and Acquisto_Sociale='no' then  '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">' 
					when Appalto_Verde='no' and Acquisto_Sociale='si' then  '<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">' 
			end as Bando_Verde_Sociale
			, az.IdAzi as AZI_Ente
			,case when TipoSedutaGara='virtuale' then case when StatoSeduta is null then 'prevista' else case when StatoSeduta='aperta' then 'incorso' else 'prevista' end  end else '' end as SedutaVirtuale
			,EnteProponente 
			, statoiscrizione
		from ctl_doc d with(nolock) 
			inner join document_bando b  with(nolock) on d.id = b.idheader
			inner join CTL_DOC_Destinatari ds  with(nolock) on  ds.idHeader = d.id
			inner join profiliutente p  with(nolock) on p.pfuidazi = ds.IdAzi
			inner join aziende az with(nolock)  on az.idazi=d.Azienda   ---per recuperare l'enteAppaltante
			left outer join (
				select max( id ) as id ,LinkedDoc , azienda from CTL_DOC  with(nolock) where TipoDoc in ('OFFERTA','OFFERTA_ASTA' ,'DOMANDA_PARTECIPAZIONE') and deleted = 0 group by LinkedDoc , azienda
				) as lo on lo.LinkedDoc = d.id and ds.idAzi = lo.azienda

			left outer join (select id , statofunzionale from CTL_DOC  with(nolock) where TipoDoc in ('OFFERTA','OFFERTA_ASTA' ,'DOMANDA_PARTECIPAZIONE' ) ) as ld on lo.id = ld.id
			--left outer join DOCUMENT_RISULTATODIGARA DR  with(nolock) on DR.ID_MSG_BANDO=-d.id and DR.TipoDoc_src=D.TipoDoc
			--left outer join
			--(
			--	select distinct id , ID_MSG_BANDO , TipoDoc_src
			--		from
			--			DOCUMENT_RISULTATODIGARA inner join 
			--			DOCUMENT_RISULTATODIGARA_ROW on idheader=id 
			--		where 
			--			isnull(TipoDoc_src,'')<>''
			--) DR on DR.ID_MSG_BANDO=-d.id and DR.TipoDoc_src=D.TipoDoc


			left outer join
			(
				select distinct leg
					from
						DOCUMENT_RISULTATODIGARA_ROW_VIEW
			
					where StatoFunzionale='Inviato'						
		 
			) DR on DR.leg=d.id 


			left  join (
			
			
					select d.linkedDoc , TipoDoc as TipoModifica  from ctl_doc d with(nolock) 
						inner join ( 
										Select max(id) as ID_DOC ,  linkedDoc from ctl_doc  with(nolock) where tipodoc IN ('RETTIFICA_BANDO','PROROGA_BANDO','RETTIFICA_GARA','PROROGA_GARA'  , 'RIPRISTINO_GARA'  ) and Statodoc ='Sended' group by linkedDoc  
										) as M on M.id_DOC = d.id
			
					) V on V.LinkedDoc=d.id
			--left outer join (Select distinct(linkedDoc) from ctl_doc with(nolock) where tipodoc='PROROGA_GARA' and statofunzionale='Inviato') V on V.LinkedDoc=d.id
			--left outer join (Select distinct(linkedDoc) from ctl_doc with(nolock) where tipodoc='RETTIFICA_GARA' and statofunzionale='Inviato') Z on Z.LinkedDoc=d.id
																					-- il tipo doc è stato troncato a 18 perchè lato fornitore il documento che apre è il
																					-- BANDO_SEMPLIFICATO_INVITO mentre il documento è BANDO_SEMPLIFICATO
			--left outer join CTL_DOC_READ r with(nolock) on  r.idPfu = p.IdPfu and left( r.DOC_NAME , 18 ) = left( d.tipoDoc ,18 ) and r.id_Doc = d.id
			left outer join ( select distinct left( r.DOC_NAME , 18 ) as DOC_NAME , 1 as id , r.idPfu , r.id_Doc from   CTL_DOC_READ r with(nolock) ) as r on  r.idPfu = p.IdPfu and left( r.DOC_NAME , 18 ) = left( d.tipoDoc ,18 ) and r.id_Doc = d.id
		where tipodoc in ( 'BANDO_SEMPLIFICATO' , 'BANDO_GARA' , 'BANDO_ASTA' ) and 
				--statofunzionale in ('Pubblicato') and 
				d.statofunzionale not in ('InLavorazione' , 'InApprove' , 'Rifiutato' , 'NotApproved','ProntoPerInviti', 'InProtocollazione' ) and 
				deleted = 0






















GO
