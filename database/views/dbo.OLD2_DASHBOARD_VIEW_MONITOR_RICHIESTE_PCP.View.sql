USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_MONITOR_RICHIESTE_PCP]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--use aflink_pa_dev


CREATE  view [dbo].[OLD2_DASHBOARD_VIEW_MONITOR_RICHIESTE_PCP] as 

		--•	Apri Procedura
		--•	Id Documento di gara
		--•	Titolo
		--•	Oggetto
		--•	Ente
		--•	CF Ente
		--•	Rup
		--•	CF Rup
		--•	LOA
		--•	Canale
		--•	Data prima richiesta PCP
		--•	Presenza CIG
		--•	Stato Funzionale
		--•	Ultimo Servizio PCP invocato
		--•	Ultima Response PCP
		--•	Id Ultimo servizio PCP invocato


		select 
				D.id , 
				P.DataInserimento as DataInvio , --
				D.TipoDoc as OPEN_DOC_NAME,--
				D.StatoFunzionale ,--
				D.Titolo , 
				D.Body as DescrizioneEstesa, 
				D.Protocollo ,
				A.aziRagionesociale ,--
				cf.vatvalore_ft as aziCodiceFiscale ,
				u.pfunome ,
				u.pfucodicefiscale as CodiceFiscaleReferente,--
				LOA.dataInsRecord as dataIns ,
				LOA.LOA as PCP_LOA, 
				case when isnull( B.cig , '' ) <> '' or not CIG.IdHeader is null  
					then 'SI' else '' end as CIG ,

				s.DataExecuted ,
				s.operazioneRichiesta ,
				s.msgError ,
				s.outputWS ,
				s.idRow , 
				AP.pcp_CodiceAppalto ,
				E.CN16_CODICE_APPALTO ,
				PI.pfunome as Compilatore ,
				AP.pcp_TipoScheda,
				schede.statoScheda as StatoSchedaPCP


			from 
				( -- tutte le procedure che hanno richiesto un servizio PCP
					select 

						s.idRichiesta  

						, min( s.dateIn) as DataInserimento
						, max( s.idRow ) as idRow

						from Services_Integration_Request s with(nolock)
						where s.integrazione = 'PCP'
						group by idRichiesta
				) P
		
				-- ultimo servizio invocato
				inner join Services_Integration_Request s with(nolock) on P.idRow = s.idRow

				-- documento collegato alla richiesta
				inner join CTL_DOC D with(nolock) on D.id = P.idRichiesta
				inner join Document_Bando B with(nolock) on b.idHeader = P.idRichiesta
				inner join Document_PCP_Appalto AP with(nolock) on AP.idHeader = P.idRichiesta
				inner join Document_E_FORM_CONTRACT_NOTICE  E with(nolock) on E.idHeader = P.idRichiesta

				-- COMPILATORE
				left join profiliutente [PI] with(nolock) on [PI].idpfu = D.IdPfu

				-- RUP
				left join ctl_doc_value r with(nolock) on r.idheader = d.id and r.dzt_name = 'UserRup' and r.dse_id = 'InfoTec_comune'
				left join profiliutente u with(nolock) on u.idpfu = r.value

				-- LOA
				left join ( select http_fiscalnumber ,  max( [dataInsRecord] ) as [dataInsRecord] , max( LOA ) as LOA from ctl_log_spid with(nolock) group by http_fiscalnumber ) as LOA on http_fiscalnumber = u.pfuCodiceFiscale

				-- verifica presenza CIG
				left join ( select DISTINCT idheader from document_microlotti_dettagli with(nolock) where tipodoc in ( 'AFFIDAMENTO_SENZA_NEGOZIAZIONE','BANDO_GARA' , 'BANDO_SEMPLIFICATO' ) and  isnull( cig , '' ) <> '' ) as CIG ON cig.IDHEADER = d.ID

				-- Ente
				inner join aziende a with(nolock) on a.idazi = cast( D.azienda as int ) 
				inner join dm_attributi cf with(nolock) on cf.lnk = a.idazi and cf.dztnome = 'codicefiscale' AND CF.IDAPP = 1

				left join Document_PCP_Appalto_Schede schede with(nolock) on schede.idheader=AP.idHeader and schede.tipoScheda=AP.pcp_TipoScheda and schede.bDeleted=0
 


GO
