USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[OLD_BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO] as 

	select b.id as idBando , lb.id as idLotto , isnull(Numerolotto,1) as N_Lotto,

		--isnull( v1.Value , CriterioAggiudicazioneGara ) as CriterioAggiudicazioneGara , 
		--isnull( v2.Value , Conformita ) as Conformita , 
		--isnull( v3.Value , CalcoloAnomalia ) as CalcoloAnomalia , 
		--isnull( v4.Value , OffAnomale ) as OffAnomale , 

		isnull( CAL.CriterioAggiudicazioneGara ,ba.CriterioAggiudicazioneGara ) as CriterioAggiudicazioneGara , 
		isnull( CAL.Conformita , ba.Conformita ) as Conformita , 
		isnull( CAL.CalcoloAnomalia , ba.CalcoloAnomalia ) as CalcoloAnomalia , 
		isnull( CAL.OffAnomale , ba.OffAnomale ) as OffAnomale , 
		isnull( CAL.ModalitaAnomalia_TEC , ba.ModalitaAnomalia_TEC ) as ModalitaAnomalia_TEC , 
		isnull( CAL.ModalitaAnomalia_ECO , ba.ModalitaAnomalia_ECO ) as ModalitaAnomalia_ECO , 


		--isnull( v5.Value , g5.Value ) as PunteggioEconomico , 
		--isnull( v6.Value , g6.Value ) as PunteggioTecnico , 
		--isnull( v7.Value , g7.Value ) as PunteggioTecMin , 
		--isnull( v8.Value , g8.Value ) as FormulaEcoSDA , 
		--isnull( v9.Value , g9.Value ) as Coefficiente_X , 
		--isnull( v10.Value , g10.Value ) as PunteggioTEC_100 , 
		--isnull( v11.Value , g11.Value ) as PunteggioTEC_TipoRip , 
		--isnull( v8.Value , g8.Value ) as FormulaEconomica ,
		--isnull( v12.Value , g12.Value ) as ModAttribPunteggio,

		isnull( CVL.PunteggioEconomico , CVG.PunteggioEconomico ) as PunteggioEconomico , 
		isnull( CVL.PunteggioTecnico , CVG.PunteggioTecnico ) as PunteggioTecnico , 
		isnull( CVL.PunteggioTecMin , CVG.PunteggioTecMin ) as PunteggioTecMin , 
		isnull( CVL.FormulaEcoSDA , CVG.FormulaEcoSDA) as FormulaEcoSDA , 
		isnull( CVL.Coefficiente_X , CVG.Coefficiente_X ) as Coefficiente_X , 
		isnull( CVL.PunteggioTEC_100 , CVG.PunteggioTEC_100 ) as PunteggioTEC_100 , 
		isnull( CVL.PunteggioTEC_TipoRip , CVG.PunteggioTEC_TipoRip ) as PunteggioTEC_TipoRip , 
		isnull( CVL.FormulaEcoSDA , CVG.FormulaEcoSDA ) as FormulaEconomica ,
		isnull( CVL.ModAttribPunteggio , CVG.ModAttribPunteggio ) as ModAttribPunteggio,

		isnull( CVL.PunteggioECO_TipoRip , CVG.PunteggioECO_TipoRip ) as PunteggioECO_TipoRip , 


		TipoSceltaContraente, 

		TipoProceduraCaratteristica,
		isnull( CVL.TipoAggiudicazione , ba.TipoAggiudicazione) as TipoAggiudicazione,
		
		--E.P. rinominata per evitare colonna duplicata se usata da qualche altro punto
		ValoreImportoLotto as Base_Asta_Lotto,
		isnull( LOTTI.num_criteri_eco  , BANDO.num_criteri_eco ) as num_criteri_eco,
		--2 as num_criteri_eco,
		isnull( LOTTI.ValutazioneSoggettiva  , BANDO.ValutazioneSoggettiva ) as ValutazioneSoggettiva

		

		

		from CTL_DOC  b  with (nolock) 

			inner join document_bando ba  with (nolock) on  ba.idheader = b.id
			left outer join document_microlotti_dettagli lb with (nolock) on b.id = lb.idheader and lb.tipodoc = b.Tipodoc and lb.Voce = 0
			
			--left outer join Document_Microlotti_DOC_Value v1  with (nolock) on v1.idheader = lb.id and v1.DZT_Name = 'CriterioAggiudicazioneGara'  and v1.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
			--left outer join Document_Microlotti_DOC_Value v2  with (nolock) on v2.idheader = lb.id and v2.DZT_Name = 'Conformita'  and v2.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
			--left outer join Document_Microlotti_DOC_Value v3  with (nolock) on v3.idheader = lb.id and v3.DZT_Name = 'CalcoloAnomalia'  and v3.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
			--left outer join Document_Microlotti_DOC_Value v4  with (nolock) on v4.idheader = lb.id and v4.DZT_Name = 'OffAnomale'  and v4.DSE_ID = 'CRITERI_AGGIUDICAZIONE'

			left outer join View_Criteri_Aggiudicazione_Lotto  CAL on CAL.idheader = lb.id

			-- criteri di valutazione economicamente vantaggiosi dello specifico lotto
			--left outer join Document_Microlotti_DOC_Value v5  with (nolock) on v5.idheader = lb.id and v5.DZT_Name = 'PunteggioEconomico'  and v5.DSE_ID = 'CRITERI_ECO'
			--left outer join Document_Microlotti_DOC_Value v6  with (nolock) on v6.idheader = lb.id and v6.DZT_Name = 'PunteggioTecnico'  and v6.DSE_ID = 'CRITERI_ECO'
			--left outer join Document_Microlotti_DOC_Value v7  with (nolock) on v7.idheader = lb.id and v7.DZT_Name = 'PunteggioTecMin'  and v7.DSE_ID = 'CRITERI_ECO'
			--left outer join Document_Microlotti_DOC_Value v8  with (nolock) on v8.idheader = lb.id and v8.DZT_Name = 'FormulaEcoSDA'  and v8.DSE_ID = 'CRITERI_ECO'
			--left outer join Document_Microlotti_DOC_Value v9  with (nolock) on v9.idheader = lb.id and v9.DZT_Name = 'Coefficiente_X'  and v9.DSE_ID = 'CRITERI_ECO'
			--left outer join Document_Microlotti_DOC_Value v10  with (nolock) on v10.idheader = lb.id and v10.DZT_Name = 'PunteggioTEC_100'  and v10.DSE_ID = 'CRITERI_ECO'
			--left outer join Document_Microlotti_DOC_Value v11  with (nolock) on v11.idheader = lb.id and v11.DZT_Name = 'PunteggioTEC_TipoRip'  and v11.DSE_ID = 'CRITERI_ECO'
			--left outer join Document_Microlotti_DOC_Value v12  with (nolock) on v12.idheader = lb.id and v12.DZT_Name = 'ModAttribPunteggio'  and v12.DSE_ID = 'CRITERI_ECO_LOTTO'

			left outer join  View_Criteri_Valutazione_Lotto CVL on  CVL.idheader = lb.id


			-- criteri di valutazione economicamente vantaggiosi della GARA ( Prevalente )

			--left outer join CTL_DOC_Value g5  with (nolock) on g5.idheader = b.id and g5.DZT_Name = 'PunteggioEconomico'  and g5.DSE_ID = 'CRITERI_ECO'
			--left outer join CTL_DOC_Value g6  with (nolock) on g6.idheader = b.id and g6.DZT_Name = 'PunteggioTecnico'  and g6.DSE_ID = 'CRITERI_ECO'
			--left outer join CTL_DOC_Value g7  with (nolock) on g7.idheader = b.id and g7.DZT_Name = 'PunteggioTecMin'  and g7.DSE_ID = 'CRITERI_ECO'
			--left outer join CTL_DOC_Value g8  with (nolock) on g8.idheader = b.id and g8.DZT_Name = 'FormulaEcoSDA'  and g8.DSE_ID = 'CRITERI_ECO'
			--left outer join CTL_DOC_Value g9  with (nolock) on g9.idheader = b.id and g9.DZT_Name = 'Coefficiente_X'  and g9.DSE_ID = 'CRITERI_ECO'
			--left outer join CTL_DOC_Value g10  with (nolock) on g10.idheader = b.id and g10.DZT_Name = 'PunteggioTEC_100'  and g10.DSE_ID = 'CRITERI_ECO'
			--left outer join CTL_DOC_Value g11  with (nolock) on g11.idheader = b.id and g11.DZT_Name = 'PunteggioTEC_TipoRip'  and g11.DSE_ID = 'CRITERI_ECO'
			--left outer join CTL_DOC_Value g12  with (nolock) on g12.idheader = b.id and g12.DZT_Name = 'ModAttribPunteggio'  and g12.DSE_ID = 'CRITERI_ECO'

			left outer join View_Criteri_Valutazione_Gara CVG on CVG.idheader = ba.idheader

			left outer join (select COUNT(*) as num_criteri_eco,MAX(idheader) as IDLOTTO, MAX ( case when FormulaEconomica = 'Valutazione soggettiva' then 1 else 0 end ) as ValutazioneSoggettiva from [BANDO_GARA_CRITERI_ECO_RIGHE_VIEW] where TipoDoc = 'LOTTO' group by idHeader) LOTTI on LOTTI.IDLOTTO = lb.id
			left outer join (select COUNT(*) as num_criteri_eco,MAX(idheader) as IDBANDO, MAX ( case when FormulaEconomica = 'Valutazione soggettiva' then 1 else 0 end ) as ValutazioneSoggettiva from [BANDO_GARA_CRITERI_ECO_RIGHE_VIEW] where TipoDoc <> 'LOTTO' group by idHeader) BANDO on BANDO.IDBANDO = ba.idheader






GO
