USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_VISION_PBM_AGGIUDICATARI_MULTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[VIEW_VISION_PBM_AGGIUDICATARI_MULTI] AS

	SELECT    t.IdHeader AS idPDA ,
			  cast( t.NumeroLotto as int ) as NumeroLotto,
			  o.IdMsg as idOfferta,

			  o.aziRagionesociale ,

			   -- Se l'azienda partecipa come RTI, passiamo come richiesto al posto del CF l'id dell'offerta ( serve a teamsystem per non "prendere" questi valori )
			   CASE WHEN o2.idrow is not null then cast( o.IdMsg as varchar) else a.vatValore_FT END AS CF ,	
			  --a.vatValore_FT AS CF ,

			  azi.aziPartitaIVA,

			  d.ValoreImportoLotto as importo_offerto,
			  round( cast(isnull(d.ValoreSconto,0) as float) / cast(-100 as float), 5 ) as perc_ra,	--Percentuale di ribasso / aumento; indicare con segno "-" se ribasso
			  case when m2.PercAgg is null or m2.PercAgg = 0 then 100 else m2.PercAgg end as percentualeAggiudicazione,
			  case when o2.idrow is not null then 1 else 0 end as rti

			  ,t.Graduatoria ,
			  t.Posizione ,
			  t.Aggiudicata ,
			  t.Exequo ,
			  d.Descrizione ,
			  d.CIG

		FROM  document_microlotti_dettagli t with(nolock)
				
				INNER JOIN ctl_doc pda with(nolock) on pda.id = t.IdHeader and pda.tipodoc = 'PDA_MICROLOTTI'
				--INNER JOIN Document_Bando ba with(nolock) on ba.idheader = pda.LinkedDoc

				inner join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO BCL on BCL.idBando = pda.LinkedDoc and BCL.N_Lotto = t.NumeroLotto

				-- ENTRO SUL DOC DI MULTI AGGIUDICAZIONE
				INNER JOIN CTL_DOC multiAgg with(nolock) ON multiAgg.LinkedDoc = t.id and multiagg.tipodoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' and multiAgg.Deleted = 0 and multiAgg.StatoFunzionale = 'Confermato'
				INNER JOIN Document_microlotti_dettagli m2 with(Nolock) on m2.IdHeader = multiAgg.id and m2.TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' and m2.NumeroLotto = t.NumeroLotto and m2.StatoRiga <> 'escluso'

				INNER JOIN aziende azi with(nolock) on azi.idazi = m2.Aggiudicata
				LEFT JOIN dm_attributi a with(nolock) ON a.lnk = azi.IdAzi AND a.dztnome = 'CodiceFiscale'

				INNER JOIN document_pda_offerte o with(nolock) ON o.idheader = t.IdHeader and o.idAziPartecipante = azi.idazi
				LEFT JOIN ctl_doc_value o2 with(nolock)  on o2.idheader = o.IdMsg and o2.DSE_ID = 'RTI' and o2.DZT_Name = 'PartecipaFormaRTI' and o2.[Value] = '1'

				INNER JOIN document_microlotti_dettagli d with(nolock) ON d.idheader = o.idrow AND d.tipodoc = 'PDA_OFFERTE' and isnull(d.voce,0) = 0 and t.NumeroLotto = d.NumeroLotto and d.StatoRiga <> 'escluso'

		WHERE  
			--isnull( TipoAggiudicazione , 'monofornitore' ) not in (  'monofornitore' , '' ) 
			isnull( BCL.TipoAggiudicazione , 'monofornitore' ) not in (  'monofornitore' , '' ) 
			and t.tipodoc = 'PDA_MICROLOTTI' and t.Voce = 0 and t.StatoRiga  in ( 'AggiudicazioneDef' , 'AggiudicazioneProvv' , 'AggiudicazioneCond' , 'Controllato' )
			and d.Posizione in ('Idoneo provvisorio' ,'Idoneo definitivo condizionato', 'Idoneo definitivo')
		--	and t.idheader = 88297 and t.NumeroLotto  = 2





GO
