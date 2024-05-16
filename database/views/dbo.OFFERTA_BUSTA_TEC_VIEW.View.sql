USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OFFERTA_BUSTA_TEC_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OFFERTA_BUSTA_TEC_VIEW] as

	SELECT
		 m.*
		,isnull(RettTec.Id,0) AS RettificaOffertaTec
		,isnull(FlagRettifica.Valore,0) as FlagRettifica
		,isnull(CommTec.UtenteCommissione,0) as PresidenteTec
		,isnull(CommEco.UtenteCommissione,0) as PresidenteEco
	FROM
		Document_microlotti_dettagli m with(nolock)
		LEFT JOIN CTL_DOC offer with(nolock) ON offer.id = m.idheader

		--Flag Attivazione Rettifica Offerta
		left join CTL_Parametri FlagRettifica with (nolock) on FlagRettifica.Contesto='CERTIFICATION' and FlagRettifica.Oggetto='certification_req_33245' and FlagRettifica.Proprieta = 'Visible'
			
		LEFT JOIN (
			SELECT
				RettTec.*,
				ROW_NUMBER() OVER (PARTITION BY RettTec.LinkedDoc ORDER BY RettTec.Id DESC) AS RowNum
			FROM
				CTL_DOC RettTec with (nolock)
			WHERE
				RettTec.TipoDoc = 'PDA_COMUNICAZIONE_GARA'
				AND RettTec.deleted = 0
				AND RettTec.StatoFunzionale = 'Inviato'
				AND SUBSTRING(RettTec.JumpCheck, 3, LEN(RettTec.JumpCheck) - 2) = 'RETTIFICA_TECNICA_OFFERTA'
		) RettTec ON RettTec.LinkedDoc = offer.id AND RettTec.RowNum = 1

		
	-- Recupero ID dei presidenti della commissione
		--Accedo al doc della commissione
		left join CTL_DOC Commissione with (nolock) on offer.linkedDoc = Commissione.linkedDoc and Commissione.tipodoc = 'COMMISSIONE_PDA' and Commissione.StatoFunzionale = 'Pubblicato'
		--IdPfu Presidente Commissione Tecnica
		left join Document_CommissionePda_Utenti CommTec with(nolock) on Commissione.id = CommTec.IdHeader and CommTec.RuoloCommissione = 15548 and CommTec.TipoCommissione = 'G'
		--IdPfu Presidente Commissione Economica
		left join Document_CommissionePda_Utenti CommEco with(nolock) on Commissione.id = CommEco.IdHeader and CommEco.RuoloCommissione = 15548 and CommEco.TipoCommissione = 'C'
	

GO
