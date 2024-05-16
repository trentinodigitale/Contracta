USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VERIFICA_ANOMALIA_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[VERIFICA_ANOMALIA_TESTATA_VIEW] as 
	select  
	d.id as idVerificaLotto,
	dett_pda.id,
	t.CIG,
	ISNULL(dett_pda.cig,ba.cig) as CIG_LOTTO,
	t.Conformita,
	c.CriterioAggiudicazioneGara,
	t.CriterioFormulazioneOfferte,
	t.CUP,
	t.DataIndizione,
	Descrizione,
	t.Divisione_lotti,
	t.Fascicolo,
	t.importoBaseAsta,
	t.importoBaseAsta2,
	ListaModelliMicrolotti,
	t.ModalitadiPartecipazione,
	ModelloOfferta_Drill,
	ModelloPDA,
	ModelloPDA_DrillLista,
	ModelloPDA_DrillTestata,
	t.NumeroIndizione,
	NumeroLotto,
	c.OffAnomale,
	isnull( OU.Value , 'SI' ) as OFFERTE_UTILI,
	Oggetto,
	t.ProtocolloRiferimento,
	dett_pda.StatoRiga,
	t.StrutturaAziendale,
	t.TipoProceduraCaratteristica,
	t.TipoSceltaContraente,
	ValoreImportoLotto,
	CV.Value as colonnatecnica


from CTL_DOC d with (nolock)
	inner join Document_MicroLotti_Dettagli dett_pda with (nolock) on d.linkeddoc=dett_pda.id
	inner join ctl_doc pda with(nolock) on dett_pda.idheader=pda.id and pda.deleted=0
	inner join document_bando ba with(nolock) on ba.idHeader=pda.LinkedDoc
	inner join PDA_MICROLOTTI_VIEW_TESTATA t with(nolock) on dett_pda.IdHeader = t.id and dett_pda.TipoDoc='pda_microlotti'
	inner join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO c with(nolock) on ba.idheader = c.idBando and dett_pda.NumeroLotto = c.N_Lotto
	left join CTL_DOC_Value CV with (nolock) on CV.idHeader=d.id and CV.DSE_ID='INFO_TECNICA' and CV.DZT_Name='OffAnomale' 
	left join CTL_DOC_Value OU with (nolock) on OU.idHeader=d.id and OU.DSE_ID='OFFERTE_UTILI' and OU.DZT_Name='OFFERTE_UTILI' 
	


GO
