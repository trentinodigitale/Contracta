USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_SIMOG_PUBBLICA_DATI_WS]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--select * from [SIMOG_PUBBLICA_DATI_WS]

CREATE VIEW [dbo].[OLD2_SIMOG_PUBBLICA_DATI_WS] AS

	SELECT gara.id as id_gara

			--- MODIFICHE POST EMAIL DI KATIA DEL 20 luglio 2021 10:18
			-- in caso di gara con
			--	 1. ‘STRUMENTO DI SVOLGIMENTO DI PROCEDURA’ (scheda gara) valorizzato con ‘SISTEMA DINAMICO DI ACQUISIZIONE’ (SDA)   -- codice 7
			--	 2. e SCELTA DEL CONTRAENTE valorizzata a ‘PROCEDURA RISTRETTA’ -- codice 2 
			-- il sistema non dovrà attivare la gestione della procedura in modalità a 2 fasi ma ad una sola fase come fosse una procedura negoziata per cui sarà necessario : 
			--	VALORIZZARE SOLO 2 DATE: data di pubblicazione e data di scadenza per la presentazione delle offerte.
			--   La ‘Data di pubblicazione’ dovrà essere valorizzata con la data della lettera d’invito ( quindi del semplificato/ appalto specifico ) per noi e non con la data del bando di istituzione dello SDA.


			, usr.[LOGIN]
			, usr.[PASSWORD]
			, dg.id_gara as simog_id_gara
			, dg.indexCollaborazione
			
			, left( isnull(link.[Value],'') , 250)  as LINK_SITO
			, isnull(qn.numQuot,0) as NUMERO_QUOTIDIANI_NAZ
			, isnull(ql.numQuot,0) as NUMERO_QUOTIDIANI_REGIONALI

			-- S06.02 [Data pubblicazione]
			-- Se sono nel caso Scelta del contranete = procedura ristretta ( 2 ) E strumento di svolgimento = sda ( 7 ) prendo getDATE()
			--  + Per le procedure classiche è getDate(), 
			--	+ per il secondo giro della ristretta è la data pubblicazione della 1a fase e per gli appalti semplificati è la Data pubblicazione SDA 
			, case when not ( dg.ID_SCELTA_CONTRAENTE = '2' and dg.STRUMENTO_SVOLGIMENTO = '7' ) and (  gara.TipoDoc = 'BANDO_SEMPLIFICATO' or ( bd.tipobandogara = 3 /*( invito )*/ and bd.proceduragara = 15477 /* ( ristretta ) */ )  )
					then CONVERT(VARCHAR(8), primafase.DataInvio,112)
					else CONVERT(VARCHAR(8), getdate(),112) 
			   end as DATA_PUBBLICAZIONE

			--<!-- S06.03.X [Data scadenza per la presentazione delle offerte] : Data scadenza presentazione offerte della procedura che si sta inviando -->
			, case when bd.DataScadenzaOfferta is null then '' else CONVERT(VARCHAR(8), bd.DataScadenzaOfferta,112) end as DATA_SCADENZA_PAG
			, case when bd.DataScadenzaOfferta is null then '' else CONVERT(VARCHAR(5), bd.DataScadenzaOfferta,108) end as ORA_SCADENZA

			, bd.DataScadenzaOfferta as TED_DATA_SCADENZA_PAG

			, dg.ID_SCELTA_CONTRAENTE 
			, isnull( cig.Versione,'') as versioneSimog -- usato ad esempio per togliere il campo 'FLAG_BENICULT' per la versione '3.4.2'

			, case when odc.RDA_IdRow is not null then 1 else 0 end HIDE_DATI_PUBBLICAZIONE

			-- S06.05.PR [Data di scadenza per la presentazione della richiesta di invito]
			-- + Se sono nel caso Scelta del contranete = procedura ristretta ( 2 ) E strumento di svolgimento = sda ( 7 ) non mando il campo. quindi NULL
			-- + se la scelta del contraente è tra quelle che prevedono i campi dataScadenzaRichiestaInvito e dataLetteraInvito ( es. scelta del contranete = 2 ( ristretta ) )
			-- + getDate() se siamo su un appalto specifico conseguente ad uno SDA.
			-- + Se siamo su una gara in 2 fase, nell'invio della seconda fase, prendiamo la data scadenza di presentazione della prima fase.  --> 
			-- + se la relazione lo prevede ( ad es. scelta del contraente 'Procedura competitiva con negoziazione' ) e siamo su un RDO come per il semplificato mandiamo getDate()
			, case when rel1.REL_idRow is null or ( dg.ID_SCELTA_CONTRAENTE = '2' and dg.STRUMENTO_SVOLGIMENTO = '7' )  then null 
				   when rel1.REL_idRow is not null and gara.TipoDoc = 'BANDO_SEMPLIFICATO' then CONVERT(VARCHAR(8), getdate(),112) 
				   when rel1.REL_idRow is not null and bd.TipoProceduraCaratteristica = 'RDO' then CONVERT(VARCHAR(8), getdate(),112) 
				   when rel1.REL_idRow is not null and isnull(gara.LinkedDoc,0) <> 0 then CONVERT(VARCHAR(8), dbprimafase.DataScadenzaOfferta,112)
				   else NULL
				   end
				as DATA_SCADENZA_RICHIESTA_INVITO

			--<!-- S06.06.PR [Data della lettera di invito] 
			-- + getDate() se sono in una scelta del contraente che prevede la data lettera di invito
			-- + Se sono nel caso Scelta del contranete = procedura ristretta ( 2 ) E strumento di svolgimento = sda ( 7 ) non mando il campo. quindi NULL
			, case when rel1.REL_idRow is not null and not ( dg.ID_SCELTA_CONTRAENTE = '2' and dg.STRUMENTO_SVOLGIMENTO = '7' ) then CONVERT(VARCHAR(8), getdate(),112)  else null end as DATA_LETTERA_INVITO

			, ted1.Value as TED_SITO_MINISTERO_INF_TRASP

		FROM CTL_DOC gara WITH(NOLOCK)
				left join Document_Bando bd with(nolock) on bd.idHeader = gara.Id
				left join ctl_doc primafase with(nolock) on primafase.Id = gara.LinkedDoc
				left join Document_Bando dbprimafase with(nolock) on dbprimafase.idHeader = primafase.id
				
					--left join ctl_doc_value rup with(nolock) on rup.idheader = gara.id and rup.dse_id = 'InfoTec_comune' and rup.dzt_name = 'UserRUP' 
					left join document_odc odc with(nolock) on odc.RDA_ID = gara.id -- per il giro cig derivati

				--inner join SIMOG_LOGIN_DATI_WS usr with(nolock) on usr.IdPfu = isnull(rup.[Value], odc.idpfuRup )

				inner join ( select linkedDoc, max(id) as id
								from ctl_doc cig with(nolock) 
								--con il kpf 491081 escludiamo indexcollaborazione a NULL per evitare l'errore verso il simog
								inner join Document_SIMOG_GARA dg with(nolocK) on dg.idHeader = cig.id and dg.indexCollaborazione is not null
								where cig.TipoDoc = 'RICHIESTA_CIG' and cig.Deleted = 0 and cig.StatoFunzionale in ( 'Inviato', 'InLavorazione', 'InvioInCorso' )
								group by LinkedDoc
							) cig1 on cig1.LinkedDoc = gara.Id
				
				inner join ctl_doc cig with(nolock) on cig.id = cig1.id
				inner join Document_SIMOG_GARA dg with(nolocK) on dg.idHeader = cig.id
				
				inner join SIMOG_LOGIN_DATI_WS usr with(nolock) on usr.IdPfu = isnull(dg.idpfuRup , odc.idpfuRup)

				left join CTL_Relations rel1 with(nolock) on rel1.REL_Type = 'SIMOG' and rel1.REL_ValueInput = 'ADD_DATE_INVITO_PUBBLICAZIONE_SCELTA_CONTRAENTE' and rel1.REL_ValueOutput = dg.ID_SCELTA_CONTRAENTE

				--left join LIB_Dictionary link with(nolock) on link.DZT_Name = 'SYS_SITO_ISTITUZIONALE_CLIENTE'
				left join ctl_doc_value link with(nolock) on link.IdHeader = gara.id and link.dse_id = 'InfoTec_2comune' and link.DZT_Name = 'SitoIstituzionale'
				left join ctl_doc_value ted1 with(nolock) on ted1.IdHeader = gara.id and ted1.dse_id = 'InfoTec_2comune' and ted1.DZT_Name = 'TED_SITO_MINISTERO_INF_TRASP'

				left join (
						
						select datePub.IdHeader, count(*) as numQuot
							from ctl_doc_value datePub with(nolock) 
							where datePub.dse_id = 'InfoTec_3DatePub' and datePub.DZT_Name = 'Quotidiani' and datePub.Value like 'N%'
							group by datePub.IdHeader

					) qn on qn.IdHeader = gara.Id


				left join (

						select datePub.IdHeader, count(*) as numQuot
							from ctl_doc_value datePub with(nolock) 
							where datePub.dse_id = 'InfoTec_3DatePub' and datePub.DZT_Name = 'Quotidiani' and datePub.Value like 'L%'
							group by datePub.IdHeader

					) ql on ql.IdHeader = gara.Id


GO
