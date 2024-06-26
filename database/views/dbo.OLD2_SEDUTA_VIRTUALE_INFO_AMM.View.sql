USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_SEDUTA_VIRTUALE_INFO_AMM]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD2_SEDUTA_VIRTUALE_INFO_AMM]

as
	select  psv.Visualizza_Dati_Amministrativi,
		sv.id
		,idMsg
		,case when CV.Value='si' then 1 else 0 end as EsisteDGUE
		,idAziPartecipante
		,aziRagioneSociale as RAGIONE_SOCIALE_FORNITORE
		,ReceivedDataMsg as DataRicezione
		,case when IsNull(ctlValue.value, '0') = '1' then  [dbo].[GetListaLottiOfferti] ( IdMsg) else '' end as NumeroLotti
		,case 
			when isnull( ctlvalue.value , '0' ) = '0' then null
			
			--KPF 437380 risolve il bug che replica le righe quando ci sono più partecipanti
			--INOLTRE DEVE RAGIONARE se ci sono le partecipanti devono sottoporre tutte il dgue per avere OK			
			when ISNULL(CV3.SIGN_ATTACH,'') <> '' and ISNULL(w.partecipanti_DGUE,0)=ISNULL(w2.partecipanti_DGUE_SEND,0) then  'ok' 
			--SE NON E' ENTRATO SOPRA ED E' RICHIESTO METTO KO
			when CV.Value='si' then 'ko'
			else NULL
		end
		 as DGUE
		, db.Divisione_lotti
		,case 
			when psv.Visualizza_Dati_Amministrativi='visualizza' and p.StatoFunzionale not in ( 'VERIFICA_AMMINISTRATIVA' , 'VALUTAZIONE_EXEQUO' ) then op.StatoPDA 
			when psv.Visualizza_Dati_Amministrativi='visualizza_sempre' then  op.StatoPDA 
			else 'HIDE' 
		end as StatoPDA_VIS_COLONNA
		, StatoPDA
		,IsNull(ctlValue.value,'0') as LettaBustaDocumentazione
		,db.InversioneBuste
	from ctl_doc sv with(nolock) 

		inner join ctl_doc b with(nolock)  on b.id = sv.LinkedDoc             
		inner join Document_Bando db with(nolock)  on b.id = db.idHeader  
		inner join ctl_doc p with(nolock)  on b.id = p.LinkedDoc and p.deleted = 0 and p.tipodoc = 'PDA_MICROLOTTI'
		inner join Document_PDA_OFFERTE op with(nolock)  on op.idheader = p.id and op.StatoPDA <> '99'
		
		left join CtL_DOC_VALUE ctlvalue with (nolock) on ctlValue.IdHeader = op.idmsg and ctlValue.DSE_ID='BUSTA_DOCUMENTAZIONE' and ctlvalue.row=0 and ctlvalue.DZT_Name='lettabusta'

		--left join OFFERTA_VIEW_DGUE CV with(nolock)  on CV.IdHeader=op.IdMsg and CV.DSE_ID='DISPLAY_DGUE' and CV.DZT_NAME='PresenzaDGUE'
		left join CTL_DOC_Value CV with (nolock) on CV.IdHeader = b.id and CV.DSE_ID='DGUE' and CV.DZT_Name='PresenzaDGUE'

		--left join OFFERTA_VIEW_DGUE CV2 with(nolock)  on CV2.IdHeader=op.IdMsg and CV2.DSE_ID='DISPLAY_DGUE' and CV2.DZT_NAME='Allegato'

		left join CTL_DOC CV3 with (nolock) on CV3.LinkedDoc = op.idmsg and CV3.TipoDoc='MODULO_TEMPLATE_REQUEST' and CV3.Deleted=0--and CV3.Jumpcheck='DGUE_MANDATARIA'

		--count per il numero di partecipanti diverse dalla mandataria
		left join ( select 
						idheader as offerta, count(*) as partecipanti_DGUE --do.AllegatoDGUE ,do.StatoDGUE
						from 
							Document_Offerta_Partecipanti do with (nolock)
						where Ruolo_Impresa <> 'Mandataria' 
						group by do.IdHeader 
					)  as W	on op.IdMsg=w.offerta
		--count per il numero di partecipanti che hanno sottoposto il DGUE
		left join ( select 
						idheader as offerta, count(*) as partecipanti_DGUE_SEND 
						from 
							Document_Offerta_Partecipanti do with (nolock)
						where ISNULL(do.AllegatoDGUE,'') <> '' and do.StatoDGUE = 'Ricevuto' 
								and Ruolo_Impresa <> 'Mandataria' 
						group by do.IdHeader 
					)  as W2	on op.IdMsg=w2.offerta		
		
		inner join Document_Parametri_Sedute_Virtuali psv with (nolock) on psv.deleted = 0 	
		
		

		




GO
