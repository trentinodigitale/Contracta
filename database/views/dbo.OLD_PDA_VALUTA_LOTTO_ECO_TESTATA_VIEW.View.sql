USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PDA_VALUTA_LOTTO_ECO_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[OLD_PDA_VALUTA_LOTTO_ECO_TESTATA_VIEW] as

	select  d.*
			, l.CIG
			, l.NumeroLotto
			, l.Descrizione
			, TipoGiudizioTecnico
			, v1.Value as PunteggioEconomico
			--, v2.Value as PunteggioTEC_TipoRip
			, criteri.ModAttribPunteggio
			, case 
				when isnull(FS.idheader,0)=0 then 'no'
				else 'si'
			  end as ValutazioneEconomicaSoggettiva 
			,case 
				when isnull(eco.idheader, 0) = 0 then 'no'
			else 'si'
		end as AmpGammaPresenzaModello
		, case 
			when isnull((select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI' and ',' + DZT_ValueDef + ',' like '%,AMPIEZZA_DI_GAMMA,%'), '') = '' then 'no'
			else 'si'
		end as PresenzaModuloAmpiezzaGamma

		--Flag Rettifica offerta Economica
		,isnull(RettEco.Id,0) AS RettificaOffertaEco

		from CTL_DOC d with (nolock)
				inner join Document_MicroLotti_Dettagli l with (nolock) on l.id = d.LinkedDoc
				left join document_pda_offerte O with (nolock) on O.idrow=l.idheader
				left join ctl_doc P with (nolock) on P.id=O.idheader
				left join document_bando B with (nolock)on B.idheader=P.linkeddoc

				left outer join CTL_DOC_Value v1 with (nolock) on P.Linkeddoc = v1.idheader and v1.DSE_ID = 'CRITERI_ECO' and v1.DZT_Name = 'PunteggioEconomico'

				left join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO criteri on criteri.idBando = P.LinkedDoc and ( criteri.N_Lotto = l.NumeroLotto or criteri.N_Lotto is null ) 

				left outer join (select distinct idheader from ctl_doc_value with (nolock) where dse_id = 'PDA_VALUTA_LOTTO_ECO' and DZT_Name = 'FormulaEcoSDA' and value = 'Valutazione soggettiva') FS
				    on FS.idheader=d.id

				--ampiezza di gamma			
				left join CTL_DOC_Value as bv with(nolock) on bv.IdHeader = B.idHeader and bv.DSE_ID = 'TESTATA_PRODOTTI' and bv.DZT_Name = 'id_modello'
				left join CTL_DOC_Value as ma with(nolock) on ma.IdHeader = CAST(bv.Value as int) and ma.DSE_ID = 'AMBITO' and ma.DZT_Name = 'TipoModelloAmpiezzaDiGamma'
				left join (select distinct  idheader from CTL_DOC_Value with(nolock) where DSE_ID = 'MODELLI' and DZT_Name = 'MOD_Offerta' and Value <> '') as eco on eco.IdHeader = CAST(ma.Value as int)

				--Flag Rettifica Offerta Economica
				left join CTL_DOC offer with(nolock) ON offer.id = O.IdMsg
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
