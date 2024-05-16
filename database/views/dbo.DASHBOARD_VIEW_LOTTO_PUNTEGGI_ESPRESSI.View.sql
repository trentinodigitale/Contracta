USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_LOTTO_PUNTEGGI_ESPRESSI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_LOTTO_PUNTEGGI_ESPRESSI] as 

	select 
		 P.idHeader 
		, P.ID as idLottoPDA 
		, P.NumeroLotto 
		, P.Cig 
		, P.Descrizione 
		, ISNULL(V.DescrizioneCriterio,'') as DescrizioneCriterio 		
		, V.idRow as DescrizioneCriterio_SORT 
		, aziRagioneSociale + ' - ' + ProtocolloOfferta as aziRagioneSociale
		, right( '00000000000' + NumRiga , 10 ) as aziRagioneSociale_SORT 
		, right( '00000000000' + NumRiga , 10 ) as aziRagioneSocialeNorm_SORT 
		, aziRagioneSociale + ' - ' + ProtocolloOfferta +  case when O.statoRiga in ('escluso' ) then ' - <i>Escluso</i >' else '' end as aziRagioneSocialeNorm
		, ISNULL(Pu.ValoreOfferto,0) as Valore
		, ISNULL(Pu.ValoreOfferto,0) as Valore_Sort
		, ISNULL(V.CriterioFormulazioneOfferte,'') as CriterioFormulazioneOfferta2
		, ISNULL(V.FormulaEcoSDA ,'') as FormulaEcoSDA
		, ISNULL(V.PunteggioMax ,'') as PunteggioMax
		, ISNULL(Pu.PunteggioRiparametrato ,Pu.Punteggio ) as Value
		--, ISNULL(V.CriterioValutazione,'') as CriterioFormulazioneOfferta2_Sort
		--, ISNULL(V.Formula ,'') as FormulaEcoSDA_Sort
		--, ISNULL(V.PunteggioMax ,'') as PunteggioMax_Sort
		--, ISNULL(Pu.PunteggioRiparametrato ,Pu.Punteggio ) as Value_Sort
		
		from Document_MicroLotti_Dettagli P with(nolock)
			inner join Document_PDA_OFFERTE d  with(nolock) on d.idheader = p.idheader			
			inner join Document_MicroLotti_Dettagli O  with(nolock) on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and P.NumeroLotto = O.NumeroLotto and O.Voce = 0	
			inner join Document_Microlotto_PunteggioLotto_ECO  Pu  with(nolock) on Pu.idHeaderLottoOff = O.ID 
			inner join Document_Microlotto_Valutazione_ECO V  with(nolock) on Pu.idRowValutazione = V.idRow --and V.CriterioValutazione = 'soggettivo'			
		where P.Voce = 0  and O.StatoRiga not in ('escluso')
GO
