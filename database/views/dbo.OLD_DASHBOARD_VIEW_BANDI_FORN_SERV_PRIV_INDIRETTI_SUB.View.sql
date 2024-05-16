USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV_INDIRETTI_SUB]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--Versione=4&data=2013-10-29&Attivita=48328&Nominativo=Enrico
--Versione=5&data=2014-02-27&Attivita=53377&Nominativo=Enrico
--Versione=6&data=2014-09-25&Attivita=63183&Nominativo=Enrico
CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV_INDIRETTI_SUB]  AS
SELECT IdMsg
     , a.IdPfu
     , iType AS msgIType
     , ISubType AS msgISubType
     , IDDOCR
     , Precisazioni
     , Name
     , bRead
     , ProtocolloBando
     , ProtocolloOfferta
     , ReceivedDataMsg
     , Oggetto
     , Tipologia
     , ExpiryDate
     , ImportoBaseAsta
     , TipoProcedura
     , StatoGD
     , a.Fascicolo
     , CriterioAggiudicazione
     , CriterioFormulazioneOfferta
     , OpenDettaglio
     , Scaduto
     , IdDoc
     , TipoBando
     , CIG
     , '' as StatoCollegati 
     , OPEN_DOC_NAME
	 , isnull(OpenOfferte,'') as OpenOfferte
	 , EnteAppaltante
	 , TipoProceduraCaratteristica
	 , protocollo
  FROM ( SELECT TMF.IdMsg
              , umIdPfu AS IdPfu
              , TMF.IType
              , TMF.ISubType
              , CASE WHEN Id IS NULL 
                        THEN 0 
                     ELSE Id 
                END AS IDDOCR 
              , CASE WHEN Id IS NULL 
                        THEN 0 
                        ELSE 1 
                END AS Precisazioni
              , Name
              , [read] AS  bRead
              , TMF.ProtocolloBando
              , ProtocolloOfferta
              , ReceivedDataMsg
--              , CASE NumProduct_BANDO_rettifiche
--                     WHEN '' THEN Object_Cover1
--                     WHEN '0' THEN Object_Cover1
--                     ELSE '<b>Bando Rettificato - </b> ' + Object_Cover1
--                END + '&nbsp;' AS Oggetto

			  ,CASE ADVANCEDSTATE

				when '7' then 	'<b>Bando Revocato - </b> '  + Object_Cover1

				else
					CASE NumProduct_BANDO_rettifiche
						WHEN '' THEN Object_Cover1
						WHEN '0' THEN Object_Cover1
						ELSE '<b>Bando Rettificato - </b> ' + Object_Cover1
					END 
			  END  + '&nbsp;' AS Oggetto

              , CASE tipoappalto
                     WHEN '' THEN ''
                     ELSE dbo.GetCodFromCodExt('Tipologia',tipoappalto )
                END AS Tipologia
              , ExpiryDate
              , ImportoBaseAsta
              , CASE ProceduraGara
                       WHEN '' THEN ''
                       ELSE dbo.GetCodFromCodExt('TipoProcedura',ProceduraGara )
                END AS tipoprocedura
              , Stato AS StatoGD
              , ProtocolBG AS Fascicolo
              , CASE AggiudicazioneGara
                       WHEN '' THEN ''
                       ELSE dbo.GetCodFromCodExt('Criterio',AggiudicazioneGara )
                END AS CriterioAggiudicazione
              , CASE CriterioFormulazioneOfferte
                       WHEN '' THEN ''
                       ELSE dbo.GetCodFromCodExt('CriterioOfferte',CriterioFormulazioneOfferte )
                END AS CriterioFormulazioneOfferta
              , '1' AS OpenDettaglio
              , CASE WHEN DP.ProtocolloBando IS NULL THEN '0'
                       ELSE '1'
                END AS Scaduto
              , TMF.IdDoc
              , TMF.TipoBando
              , TMF.CIG
              , '' AS OPEN_DOC_NAME
			  , TMF.RagSoc as EnteAppaltante	
			  ,'' as TipoProceduraCaratteristica
			  ,'' as Protocollo
           FROM TAB_UTENTI_MESSAGGI tu with(nolock) 
              , ( SELECT DISTINCT id 
                                , mfFieldValue AS IdDoc 
                    FROM DOCUMENT_RISULTATODIGARA with(nolock) 
                       , DOCUMENT_RISULTATODIGARA_ROW with(nolock) 
                       , MessageFields  with(nolock) 
                   WHERE IdHeader = id 
                     AND mfIdMsg = ID_MSG_BANDO  
                     AND mfFieldName = 'IdDoc'
                 ) V 
           RIGHT OUTER JOIN MessageFields mf  with(nolock) ON v.IdDoc = mf.mfFieldValue
              , TAB_MESSAGGI_FIELDS TMF  with(nolock) 
            LEFT OUTER JOIN ( SELECT DISTINCT ProtocolloBando 
                                             , Storico 
                                             , StatoProgetto 
                                FROM  document_progetti with(nolock) 
                             ) DP ON TMF.ProtocolloBando = DP.ProtocolloBando 
                                       AND DP.Storico = 0 
                                       AND DP.StatoProgetto = 'garaconclusa'			
         WHERE umIdMsg = TMF.IdMsg  
           AND TMF.ISubType = 168
           AND TMF.IType = 55
           AND umInput = 0
           AND umStato = 0
           AND umIdPfu > 0
           AND TMF.IdMsg = mfIdMSg
           AND mfFieldName = 'IdDoc'
		AND  
		(
			(ProceduraGara = 15476 AND TipoBando = 2) 
			OR
			(ProceduraGara = 15477 AND TipoBando = 2)
			OR
			(
				( ProceduraGara = 15475 OR ProceduraGara = 15478) 
				AND 
				TipoBando = 1
			)
			OR
			(ProceduraGara = 15477 AND TipoBando = 3) 
			OR
			(
				(ProceduraGara = 15475 OR ProceduraGara = 15478) 
				AND 
				TipoBando = 3
			)
			 )
		) AS a 
	--commentata per KPF 43317
	--LEFT OUTER JOIN MSG_LINKED_STATO_RISPOSTA r ON  a.Fascicolo =r.Fascicolo AND r.IdPfu = a.IdPfu
	--LEFT OUTER JOIN OLD_MSG_LINKED_STATO_RISPOSTA_ADVANCED r ON  a.Fascicolo =r.Fascicolo AND r.IdPfu = a.IdPfu
	left outer join MSG_LINKED_STATO_RISPOSTA_ADVANCED r1  with(nolock) on  a.IdDoc =r1.IdDocSource and r1.IdPfu = a.IdPfu


	union all
	--AGGIUNTI I NUOVI BANDI
	
		select 
			d.id as IdMsg, 
			p.IdPfu, 
			1000 as msgIType, 
			case 
				when tipodoc = 'BANDO_SEMPLIFICATO' then 222 
				when tipodoc = 'BANDO_GARA' then 168
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
			else
				case when isnull(v.linkeddoc,0) > 0 or isnull(z.linkeddoc,0) > 0 
					 then '<strong>Bando Rettificato - </strong> ' + cast( Body as nvarchar(4000)) 
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
				end as CriterioAggiudicazione, 
			case CriterioFormulazioneOfferte 
				when 15536 then 1 
				when 15537 then 2
				else 0 
				end as CriterioFormulazioneOfferta, 
			'1' as OpenDettaglio ,
			'0' as Scaduto, -- da capire quando scade
			cast( GUID as varchar (50) ) as IdDoc, 
			TipoBandoGara as TipoBando, 
			CIG,
			case ld.statofunzionale
				when 'InLavorazione' then 'Saved'
				when 'Sended' then 'Sended'
				when 'Inviato' then 'Sended'
				when 'Annullato' then 'Annullata'
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
				else ''
			end as OpenOfferte
			,az.AziRagioneSociale AS EnteAppaltante 
			, TipoProceduraCaratteristica
			, d.protocollo
		from ctl_doc d with(nolock) 
			inner join document_bando b  with(nolock) on d.id = b.idheader
			inner join CTL_DOC_Destinatari ds  with(nolock) on  ds.idHeader = d.id
			inner join profiliutente p  with(nolock) on p.pfuidazi = ds.IdAzi
			inner join aziende az with(nolock)  on az.idazi=d.Azienda   ---per recuperare l'enteAppaltante
			left outer join (
				select max( id ) as id ,LinkedDoc , azienda from CTL_DOC with(nolock)  where TipoDoc = 'OFFERTA' and deleted = 0 group by LinkedDoc , azienda
				) as lo on lo.LinkedDoc = d.id and ds.idAzi = lo.azienda
			left outer join (select id , statofunzionale from CTL_DOC with(nolock)  where TipoDoc = 'OFFERTA') as ld on lo.id = ld.id
			--left outer join DOCUMENT_RISULTATODIGARA DR  with(nolock) on DR.ID_MSG_BANDO=-d.id and DR.TipoDoc_src=D.TipoDoc
			left outer join
			(
				select distinct leg
					from
						DOCUMENT_RISULTATODIGARA_ROW_VIEW
					where StatoFunzionale='Inviato'						
			) DR on DR.leg=d.id 
			left outer join (Select distinct(linkedDoc) from ctl_doc with(nolock) where tipodoc='PROROGA_GARA') V on V.LinkedDoc=d.id
			left outer join (Select distinct(linkedDoc) from ctl_doc with(nolock) where tipodoc='RETTIFICA_GARA') Z on Z.LinkedDoc=d.id
																					-- il tipo doc è stato troncato a 18 perchè lato fornitore il documento che apre è il
																					-- BANDO_SEMPLIFICATO_INVITO mentre il documento è BANDO_SEMPLIFICATO
			left outer join CTL_DOC_READ r with(nolock) on  r.idPfu = p.IdPfu and left( r.DOC_NAME , 18 ) = left( d.tipoDoc ,18 ) and r.id_Doc = d.id
		where tipodoc in ( 'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and 
				--statofunzionale in ('Pubblicato') and 
				d.statofunzionale not in ('InLavorazione' , 'InApprove' ) and 
				deleted = 0







GO
