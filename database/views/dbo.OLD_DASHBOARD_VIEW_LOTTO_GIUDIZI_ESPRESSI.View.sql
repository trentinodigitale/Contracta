USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_LOTTO_GIUDIZI_ESPRESSI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[OLD_DASHBOARD_VIEW_LOTTO_GIUDIZI_ESPRESSI] as 

	select 
		P.idHeader 
		, P.ID as idLottoPDA 
		, P.NumeroLotto 
		, P.Cig 
		, P.Descrizione 
		, V.DescrizioneCriterio 
		, V.idRow as DescrizioneCriterio_SORT 
		, aziRagioneSociale + ' - ' + ProtocolloOfferta as aziRagioneSociale
		, right( '00000000000' + NumRiga , 10 ) as aziRagioneSociale_SORT 
		--, aziRagioneSociale + ' - ' + ProtocolloOfferta as aziRagioneSociale_SORT 
		, Note 
		, Punteggio as PunteggioTecnico 
		, PunteggioRiparametrato 
		, Giudizio as GiudizioTecnico
		, O.ID 
		, V.idRow
		, PunteggioMax 
		, GiudizioRiparametrato
		, cast( Giudizio as float ) as Coefficiente

		--, case when O.statoRiga in ('escluso' ) then 'escluso' else '' end as StatoRiga
		, O.StatoRiga
		, aziRagioneSociale + ' - ' + ProtocolloOfferta +  case when O.statoRiga in ('escluso' ) then ' - <i>Escluso</i >' else '' end as aziRagioneSocialeNorm
		--, aziRagioneSociale + ' - ' + ProtocolloOfferta as aziRagioneSocialeNorm_SORT 
		, right( '00000000000' + NumRiga , 10 ) as aziRagioneSocialeNorm_SORT 
		, NumRiga
		, CriterioValutazione 
		,O.PunteggioTecnicoRiparTotale

		from Document_MicroLotti_Dettagli P
			inner join Document_PDA_OFFERTE d on d.idheader = p.idheader
			-- old 2 inner join Document_MicroLotti_Dettagli O on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and O.statoRiga in ('Valutato' , 'Conforme') and P.NumeroLotto = O.NumeroLotto and O.Voce = 0
			-- old 2 inner join Document_MicroLotti_Dettagli O on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and O.statoRiga not in ('escluso' , '') and P.NumeroLotto = O.NumeroLotto and O.Voce = 0
	
			-- old 1 inner join Document_MicroLotti_Dettagli O on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and O.statoRiga not in ('escluso' ) and ( P.statoRiga not in ('InValutazione' ) or ( p.Statoriga in ('InValutazione')  and O.statoRiga <> '' )) and P.NumeroLotto = O.NumeroLotto and O.Voce = 0
			inner join Document_MicroLotti_Dettagli O on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and P.NumeroLotto = O.NumeroLotto and O.Voce = 0
	
			inner join Document_Microlotto_PunteggioLotto  Pu on Pu.idHeaderLottoOff = O.ID 
			inner join Document_Microlotto_Valutazione V on Pu.idRowValutazione = V.idRow --and V.CriterioValutazione = 'soggettivo'

			where P.Voce = 0 









GO
