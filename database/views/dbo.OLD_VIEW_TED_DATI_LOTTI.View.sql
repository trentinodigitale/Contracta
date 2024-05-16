USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_TED_DATI_LOTTI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_VIEW_TED_DATI_LOTTI] AS 
	select b.Id as idGara,
			' TED_LOT_NO TED_TITOLO_APPALTO TED_CRITERIO_AGG_LOTTO TED_PRES_OFFERTE_CATALOGO_ELETTRONICO IMPORTO_LOTTO IMPORTO_ATTUAZIONE_SICUREZZA IMPORTO_OPZIONI CIG ' as NotEditable,
			case when isnull(d.CIG,'') = '' then ba.CIG else d.cig end as CIG,
			d.NumeroLotto as TED_LOT_NO, 
			left(d.Descrizione,400) as TED_TITOLO_APPALTO,
			--isnull(c1.value, sl.LUOGO_ISTAT) as TED_LUOGO_ESECUZIONE_PRINCIPALE,
			lb.DMV_DescML as TED_LUOGO_ESECUZIONE_PRINCIPALE,
			--Valore suggerito 2 se gara SATER oepv o costo fisso o prezzoalto, 1 altrimenti
			--case when ba.CriterioAggiudicazioneGara = 15532 or ba.CriterioAggiudicazioneGara = 25532 or ba.CriterioAggiudicazioneGara = 16291 then 2 else 1 end as TED_CRITERIO_AGG_LOTTO,
			2 as TED_CRITERIO_AGG_LOTTO,
			null as TED_TIPO_CRITERIO,
			null as TED_CRITERIO_COSTO,
			--case when ba.CriterioAggiudicazioneGara = 15532 or ba.CriterioAggiudicazioneGara = 25532 or ba.CriterioAggiudicazioneGara = 16291 then 100 else null end TED_CRITERIO_PREZZO,
			null as TED_CRITERIO_PREZZO,
			null as TED_ACCETTATE_VARIANTI,
			ba.DESCRIZIONE_OPZIONI as TED_DESCRIZIONE_OPZIONI,
			'S' as TED_PRES_OFFERTE_CATALOGO_ELETTRONICO,
			'N' as TED_FLAG_APPALTO_PROGETTO_UE,
			null as TED_APPALTO_PROGETTO_UE,

			d.ValoreImportoLotto + ISNULL(d.IMPORTO_ATTUAZIONE_SICUREZZA,0) + ISNULL(d.IMPORTO_OPZIONI,0) as [IMPORTO_LOTTO],
			ISNULL(d.IMPORTO_ATTUAZIONE_SICUREZZA,0) as IMPORTO_ATTUAZIONE_SICUREZZA,
			ISNULL(d.IMPORTO_OPZIONI,0) as IMPORTO_OPZIONI

		from ctl_doc b with(nolock) 
				inner join document_bando ba with(nolock) on ba.idHeader = b.id
				inner join Document_MicroLotti_Dettagli d with(nolock) on d.IdHeader = b.id and b.TipoDoc = d.TipoDoc and d.voce = 0 

				--left join ctl_doc S with(nolock) on S.LinkedDoc = b.id and S.deleted = 0 and s.TipoDoc = 'RICHIESTA_CIG' and S.StatoFunzionale =  'Inviato' 
				--left join Document_SIMOG_LOTTI sl with(nolock) on sl.idHeader = s.Id and sl.CIG = d.CIG --match valido per le gare a lotti

				left join ctl_doc_value c1 with(nolock) on c1.idheader = b.id and c1.dse_id = 'InfoTec_SIMOG' and c1.dzt_name = 'COD_LUOGO_ISTAT' 

				left join LIB_DomainValues lb with(nolock) on lb.DMV_DM_ID = 'GEO' and lb.DMV_Cod = c1.Value
GO
