USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PDA_MICROLOTTI_VIEW_TESTATA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_PDA_MICROLOTTI_VIEW_TESTATA] as

	--select a.*
	--		,	cp.value as AttivaFilePending
	--		,	rup.Value as UserRUP
	--	from (

			select 
				d.* 
				, t.* 
				, ModelloPDA
				, ModelloPDA_DrillTestata
				, ModelloPDA_DrillLista
				, ModelloOfferta_Drill
				, Divisione_lotti
				, StatoRiga
				, l.Exequo
				--, isnull(CU.UtenteCommissione,0) as PresAgg
				, coalesce(CEco.UtenteCommissione,CU.UtenteCommissione,0) as PresAgg
				, isnull(CTA.APS_State,0) as comando_eseguito
				, CalcoloAnomalia

				--sono state aggiunte alla tabella Document_PDA_TESTATA incluse con t.*
				--, v1.Value as PunteggioTEC_100
				--, v2.Value as PunteggioTEC_TipoRip
		
		
				, isnull(B.TipoSceltaContraente,'') as TipoSceltaContraente
				,ISNULL(CU.UtenteCommissione,0) as presidente_commissione

				, case when not CSA.id is null then 'SI' else '' end as ESISTENZA_RICHIESTA_CALCOLO_ANOMALIA

				, case when CT.DataScadenza < GETDATE()  or ISNULL(num.count_risposte_da_inviare,1) = 0 or num.LinkedDoc is null then '1' else '0' end as CAN_TERMINA

				, gara.DataInvio as DataInvioGara

				, case when isnull(offers.numOff,0) < 5 and RICHIESTA_CALCOLO_ANOMALIA = 'SI' and gara.DataInvio >= '2017-05-20' then '1' else '0' end as bloccaVerificaAnomalia

		
				,1 as APERTURA_BUSTE
				,1 as APERTURA_BUSTE_TECNICHE

				, isnull(CTec.UtenteCommissione,0) as PresTec
				, case when StatoRiga in ( 'daValutare', 'InValutazione' ) then '1' else '0' end as InValutazione
				, b.TipoAggiudicazione , b.RegoleAggiudicatari
				,ISNULL(b.TipoProceduraCaratteristica,'') as TipoProceduraCaratteristica

				, case when ISNULL( attivaInvito.numDom, 0) > 0 then '0' else '1' end as attivaInvito
				, case when b.TipoBandoGara = '2' and b.ProceduraGara = '15477' then '1' else '0' end as bandoRistretta
				, dbo.ListRiferimentiBando(d.linkeddoc , 'Bando' ) as UsersRiferimentiBando
				, b.TipoSedutaGara
				,ISNULL(b.StatoSeduta,'chiusa') as StatoSeduta
				,IsNull(b.StatoChat, 'CLOSE') as StatoChat
				,o.Value as OwnerChat
		
				,Case 
					when psv.Apertura='manuale' then '1'
					when psv.Apertura='automatica' and psv.Chiusura = 'ammessa' then '1'
					else '0'
				end as ATTIVA_COMANDI_PDA_SEDUTA
				,isnull(b.Concessione,'no') as Concessione
				, case when gara.DataInvio < '2019-04-19' then '1' else '0' end as SCELTA_CRITERIO_CALCOLO_ANOMALIA
				, b.Visualizzazione_Offerta_Tecnica

				--RECUPERO DEL PARAMETRO per la rappresentazione dei riepiloghi tecnici ed economici ( riepilogo finale ) , 
				--di base in presenza di riparametrazione vengono nascoste le colonne dei punteggi non riparametrati. 
				--questo parametro consente di non nascondere le colonne consentendo di avere un raffronto fra il punteggio ottenuto 
				--con la riparametrazione e quello ottenuto inizialmente.
				--, dbo.PARAMETRI('PDA_MICROLOTTI','PUNTEGGI_ORIGINALI','SHOW','NO',-1) as PUNTEGGI_ORIGINALI
				, pa.PUNTEGGI_ORIGINALI
				, b.InversioneBuste
				, b.GeneraConvenzione
				, b.Accordo_di_Servizio
				, numOff as NumeroOfferte
				
				, gara.id as gara_id
				, cp.value as AttivaFilePending
				, rup.Value as UserRUP
				, dbo.Get_Utenti_Commissione(COM.id) as Lista_Utenti_Commissione 
				--,b.METODO_DI_CALCOLO_ANOMALIA

				,case when b.CriterioAggiudicazioneGara = '15531' and b.OffAnomale <> '16311' and isnull(b.METODO_DI_CALCOLO_ANOMALIA,0) = ''
					then dbo.get_METODO_DI_CALCOLO_ANOMALIA(b.idHeader)--isnull(MetodoSorteggiato,'')
				else 
					b.METODO_DI_CALCOLO_ANOMALIA
				end as METODO_DI_CALCOLO_ANOMALIA

				,b.ScontoDiRiferimento

			 from CTL_DOC d with(nolock)

					inner join Document_PDA_TESTATA t with(nolock) on d.id = t.idheader
					inner join document_bando b with(nolock) on b.idheader = d.Linkeddoc
					inner join ctl_doc gara with(nolock) on gara.id = d.LinkedDoc

						-- queste 2 join sulla ctl_doc_value sono state spostate fuori dalla inner query in alto perchè utilizzate al suo interno rallentavano molto la vista. anche forzando l'indice
						left join ctl_doc_value rup with(nolock, index(ICX_CTL_DOC_VALUE_IdHeader_DSE_id_DZT_name)) on rup.idHeader = gara.id and  rup.dzt_name = 'UserRup' and rup.dse_id = 'InfoTec_comune'
						left join ctl_doc_value cp with(nolock, index(ICX_CTL_DOC_VALUE_IdHeader_DSE_id_DZT_name)) on cp.IdHeader = gara.id and cp.DSE_ID = 'PARAMETRI' and cp.DZT_Name = 'AttivaFilePending' -- parametro della gara
						

					left outer join Document_Modelli_MicroLotti m with(nolock) on m.Codice = t.ListaModelliMicrolotti
					left outer join Document_Microlotti_Dettagli l with(nolock) on l.idheader = d.id and l.tipoDoc = 'PDA_MICROLOTTI' and l.Voce = 0 and l.NumeroLotto = '1'
					left outer join ctl_doc COM with(nolock) on COM.linkeddoc=d.linkeddoc and COM.tipodoc='COMMISSIONE_PDA' and COM.deleted=0 and COM.statofunzionale='pubblicato'
					left outer join Document_CommissionePda_Utenti CU with(nolock) on COM.id=CU.idheader and CU.TipoCommissione='A' and CU.ruolocommissione='15548'
					left outer join Document_CommissionePda_Utenti CEco with(nolock) on COM.id=CEco.idheader and CEco.TipoCommissione='C' and CEco.ruolocommissione='15548'
					left outer join Document_CommissionePda_Utenti CTec with(nolock) on COM.id=CTec.idheader and CTec.TipoCommissione='G' and CTec.ruolocommissione='15548'
					left join CTL_ApprovalSteps CTA with(nolock) on CTA.APS_ID_DOC=d.id and ctA.APS_Doc_Type='PDA_MICROLOTTI' and CTA.APS_State='PDA_AVVIO_APERTURE_BUSTE_TECNICHE'

					---recupero le info per capire se esiste già una richiesta di calcolo anomalia
					--left join ctl_doc CSA with(nolock) on CSA.LinkedDoc=d.Id and CSA.TipoDoc = 'CRITERIO_CALCOLO_ANOMALIA' and CSA.Deleted=0
					left join ctl_doc CSA with(nolock) on CSA.LinkedDoc=d.Id and CSA.Deleted=0
					
					--recupero il documento di offerta migliorativa se esiste
					left join ctl_doc CT with(nolock) on CT.tipodoc='PDA_COMUNICAZIONE' and CT.LinkedDoc=d.id and CT.VersioneLinkedDoc=l.id and CT.StatoFunzionale in ( 'Inviato','Inviata Risposta') and CT.JumpCheck='1-OFFERTA'

					--recupero numero di risposte da inviare
					left join ( select count(*) as count_risposte_da_inviare,LinkedDoc from ctl_doc with(nolock) where  tipodoc='PDA_COMUNICAZIONE_OFFERTA'  and statofunzionale <> 'Inviata Risposta' group by LinkedDoc ) as num on num.LinkedDoc=CT.id

					left join (  select count(IdHeader) as numOff, IdHeader from Document_PDA_OFFERTE with(nolocK) where StatoPDA in ( '2' , '22', '222' ,'8' ,'9') group by IdHeader ) as offers on offers.IdHeader = d.id

					-- join per testare se tutte le domande di partecipazione sono state messe ad ammesse o ad escluse ( per poter attivare il comando 'Crea Invito' )
					left join (  select count(IdHeader) as numDom, IdHeader from Document_PDA_OFFERTE with(nolocK) where TipoDoc = 'DOMANDA_PARTECIPAZIONE' and StatoPDA not in ( '1' , '2', '99' ) group by IdHeader ) as attivaInvito on attivaInvito.IdHeader = d.id
					left outer join CTL_DOC_Value o with(nolock) on o.IdHeader = d.id and o.DSE_ID = 'CHAT' and o.DZT_Name = 'OwnerChat'	
		
					cross join Document_Parametri_Sedute_Virtuali psv with(nolock)  
					
					cross join ( select  dbo.PARAMETRI('PDA_MICROLOTTI','PUNTEGGI_ORIGINALI','SHOW','NO',-1) as PUNTEGGI_ORIGINALI ) as PA

					--left outer join ( select  
					--					bando.id as IdHeaderSorteggio,
					--					'Metodo ' + upper(RIGHT( DZT_Name, 1 )) as MetodoSorteggiato
					--				from ctl_doc_value criterio
					--					inner join ctl_doc criterioDoc on criterio.idheader = criterioDoc.id
					--					inner join ctl_doc pda on criterioDoc.linkedDoc = pda.id
					--					inner join ctl_doc bando on pda.linkedDoc = bando.id
					--				where dse_id = 'criteri' and value = '1') as infoSorteggio on infoSorteggio.IdHeaderSorteggio= b.IdHeader

			where psv.deleted = 0 	
			
		--) a

		--	-- queste 2 join sulla ctl_doc_value sono state spostate fuori dalla inner query in alto perchè utilizzate al suo interno rallentavano molto la vista. anche forzando l'indice
		--	left join ctl_doc_value rup with(nolock, index(ICX_CTL_DOC_VALUE_IdHeader_DSE_id_DZT_name)) on rup.idHeader = gara_id and  rup.dzt_name = 'UserRup' and rup.dse_id = 'InfoTec_comune'
		--	left join ctl_doc_value cp with(nolock, index(ICX_CTL_DOC_VALUE_IdHeader_DSE_id_DZT_name)) on cp.IdHeader = gara_id and cp.DSE_ID = 'PARAMETRI' and cp.DZT_Name = 'AttivaFilePending' -- parametro della gara
		
		 
GO
