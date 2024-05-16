USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_PDA_VALUTA_LOTTO_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE view [dbo].[OLD2_PDA_VALUTA_LOTTO_VIEW] as

	SELECT
		 d.*
		,isnull(RettTec.Id,0) AS RettificaOffertaTec
		,isnull(RettEco.Id,0) AS RettificaOffertaEco
		,isnull(FlagRettifica.Valore,0) as FlagRettifica
	FROM
		CTL_DOC d with(nolock)
		LEFT JOIN Document_microlotti_dettagli m with(nolock) ON m.id = d.LinkedDoc
		LEFT JOIN Document_PDA_Offerte pda with(nolock) ON m.idheader = pda.idRow
		LEFT JOIN CTL_DOC offer with(nolock) ON offer.id = pda.IdMsg

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
		LEFT JOIN (
			SELECT
				RettEco.*,
				ROW_NUMBER() OVER (PARTITION BY RettEco.LinkedDoc ORDER BY RettEco.Id DESC) AS RowNum
			FROM
				CTL_DOC RettEco with (nolock)
			WHERE
				RettEco.TipoDoc = 'PDA_COMUNICAZIONE_GARA'
				AND RettEco.deleted = 0
				AND RettEco.StatoFunzionale = 'Inviato'
				AND SUBSTRING(RettEco.JumpCheck, 3, LEN(RettEco.JumpCheck) - 2) = 'RETTIFICA_ECONOMICA_OFFERTA'
		) RettEco ON RettEco.LinkedDoc = offer.id AND RettEco.RowNum = 1;

GO
