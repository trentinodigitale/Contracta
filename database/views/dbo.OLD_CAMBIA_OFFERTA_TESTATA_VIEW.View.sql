USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_CAMBIA_OFFERTA_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD_CAMBIA_OFFERTA_TESTATA_VIEW] as

	select d.* , l.CIG , l.NumeroLotto , l.Descrizione, TipoGiudizioTecnico
		, v1.Value as PunteggioTEC_100
		, v2.Value as PunteggioTEC_TipoRip	
		from CTL_DOC d
			inner join Document_Microlotto_PunteggioLotto pu on pu.idrow = d.LinkedDoc
			inner join Document_MicroLotti_Dettagli l on l.id = pu.idHeaderLottoOff
			left join document_pda_offerte O on O.idrow=l.idheader
			left join ctl_doc P on P.id=O.idheader
			left join document_bando B on B.idheader=P.linkeddoc

			left outer join CTL_DOC_Value v1 on P.Linkeddoc = v1.idheader and v1.DSE_ID = 'CRITERI_ECO' and v1.DZT_Name = 'PunteggioTEC_100'
			left outer join CTL_DOC_Value v2 on P.Linkeddoc = v2.idheader and v2.DSE_ID = 'CRITERI_ECO' and v2.DZT_Name = 'PunteggioTEC_TipoRip'



GO
