USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PDA_VALUTA_LOTTO_TEC_OFFERTA_BUSTA_TEC_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_PDA_VALUTA_LOTTO_TEC_OFFERTA_BUSTA_TEC_VIEW] as 

		select v.id as idLottoOfferto , D.*
			from CTL_DOC v
				inner join document_microlotti_dettagli S on v.linkedDoc = S.id
				inner join document_microlotti_dettagli D on D.idheaderlotto = S.idheaderlotto and D.tipodoc = 'PDA_OFFERTE' and s.idheader = d.idheader

				inner join document_pda_offerte o on o.idrow = D.idHeader
				inner join CTL_DOC P on P.id = o.IdHeader
				inner join document_bando B on b.idHeader = P.LinkedDoc

			where ( b.Divisione_lotti = '0' and D.Voce <> 0 ) or ( b.Divisione_lotti <> '0' )





GO
