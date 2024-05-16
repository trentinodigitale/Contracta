USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_RETT_VALORE_ECONOMICO_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_RETT_VALORE_ECONOMICO_TESTATA_VIEW] as

	-- CTE Flag Rettifica Offerta Economica
	WITH CTE_RettEco AS (
    SELECT
        RettEco.*,
        ROW_NUMBER() OVER (PARTITION BY RettEco.LinkedDoc ORDER BY RettEco.Id DESC) AS RowNum
    FROM
        CTL_DOC RettEco WITH (NOLOCK)
    WHERE
        RettEco.TipoDoc = 'PDA_COMUNICAZIONE_GARA'
        AND RettEco.deleted = 0
        AND RettEco.StatoFunzionale = 'Inviato'
        AND SUBSTRING(RettEco.JumpCheck, 3, LEN(RettEco.JumpCheck) - 2) = 'RETTIFICA_ECONOMICA_OFFERTA'
	)

	select 
		 R.* 
		,l.CIG 
		,l.NumeroLotto 
		,l.Descrizione
		,b.Divisione_lotti		
		--Flag Rettifica offerta Economica
		,isnull(CTE_RettEco.Id,0) AS RettificaOffertaEco

		from ctl_doc R 
			inner join Document_MicroLotti_Dettagli l on l.id=r.LinkedDoc and l.tipodoc='PDA_OFFERTE'
			left join document_pda_offerte O on O.idrow=l.idheader
			left join ctl_doc PDA on PDA.id=O.idheader
			left join document_bando B on B.idheader=PDA.linkeddoc
			LEFT JOIN CTL_DOC offer WITH (NOLOCK) ON offer.id = O.IdMsg
			LEFT JOIN CTE_RettEco ON CTE_RettEco.LinkedDoc = offer.id AND CTE_RettEco.RowNum = 1
	
	where R.tipodoc='RETT_VALORE_ECONOMICO'

	


GO
