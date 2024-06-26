USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_SEMP_OFF_EVAL_CRITERI_AGGIUDICAZIONE_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_BANDO_SEMP_OFF_EVAL_CRITERI_AGGIUDICAZIONE_VIEW] as 

select isnull( c.IdRow , 0 ) as IdRow
	, l.id as IdHeader
	,'CRITERI_AGGIUDICAZIONE' as DSE_ID
	, isnull( c.Row , 0 ) as Row
	, 'CriterioAggiudicazioneGara' as DZT_Name
	,isnull( c.Value , CriterioAggiudicazioneGara ) as Value
	
	from document_microlotti_dettagli l
		inner join document_Bando v on l.idheader = v.idHeader 
		left outer join Document_Microlotti_DOC_Value c on c.idheader = l.id and c.DSE_ID = 'CRITERI_AGGIUDICAZIONE' and  c.DZT_Name = 'CriterioAggiudicazioneGara'

union all

select isnull( c.IdRow , 0 ) as IdRow
	, l.id as IdHeader
	,'CRITERI_AGGIUDICAZIONE' as DSE_ID
	, isnull( c.Row , 0 ) as Row
	, 'Conformita' as DZT_Name
	,isnull( c.Value , Conformita ) as Value
	
	from document_microlotti_dettagli l
		inner join document_Bando v on l.idheader = v.idHeader 
		left outer join Document_Microlotti_DOC_Value c on c.idheader = l.id and c.DSE_ID = 'CRITERI_AGGIUDICAZIONE' and  c.DZT_Name = 'Conformita'

union all

select isnull( c.IdRow , 0 ) as IdRow
	, l.id as IdHeader
	,'CRITERI_AGGIUDICAZIONE' as DSE_ID
	, isnull( c.Row , 0 ) as Row
	, 'CalcoloAnomalia' as DZT_Name
	,isnull( c.Value , CalcoloAnomalia ) as Value
	
	from document_microlotti_dettagli l
		inner join document_Bando v on l.idheader = v.idHeader 
		left outer join Document_Microlotti_DOC_Value c on c.idheader = l.id and c.DSE_ID = 'CRITERI_AGGIUDICAZIONE' and  c.DZT_Name = 'CalcoloAnomalia'
	
union all

select isnull( c.IdRow , 0 ) as IdRow
	, l.id as IdHeader
	,'CRITERI_AGGIUDICAZIONE' as DSE_ID
	, isnull( c.Row , 0 ) as Row
	, 'OffAnomale' as DZT_Name
	,isnull( c.Value , OffAnomale ) as Value
	
	from document_microlotti_dettagli l
		inner join document_Bando v on l.idheader = v.idHeader 
		left outer join Document_Microlotti_DOC_Value c on c.idheader = l.id and c.DSE_ID = 'CRITERI_AGGIUDICAZIONE' and  c.DZT_Name = 'OffAnomale'
	

union all

select 0 as IdRow
	, l.id as IdHeader
	,'CRITERI_AGGIUDICAZIONE' as DSE_ID
	, 0 as Row
	, 'CriterioFormulazioneOfferte' as DZT_Name
	,CriterioFormulazioneOfferte as Value
	
	from document_microlotti_dettagli l
		inner join document_Bando v on l.idheader = v.idHeader 
		
union all

select 0 as IdRow
	, l.id as IdHeader
	,'CRITERI_AGGIUDICAZIONE' as DSE_ID
	, 0 as Row
	, 'RichiestaCampionatura' as DZT_Name
	,RichiestaCampionatura as Value
	
	from document_microlotti_dettagli l
		inner join document_Bando v on l.idheader = v.idHeader 


union all

select isnull( c.IdRow , 0 ) as IdRow
	, l.id as IdHeader
	,'CRITERI_AGGIUDICAZIONE' as DSE_ID
	, isnull( c.Row , 0 ) as Row
	, 'ModalitaAnomalia_ECO' as DZT_Name
	,isnull( c.Value , ModalitaAnomalia_ECO ) as Value
	
	from document_microlotti_dettagli l
		inner join document_Bando v on l.idheader = v.idHeader 
		left outer join Document_Microlotti_DOC_Value c on c.idheader = l.id and c.DSE_ID = 'CRITERI_AGGIUDICAZIONE' and  c.DZT_Name = 'ModalitaAnomalia_ECO'

union all

select isnull( c.IdRow , 0 ) as IdRow
	, l.id as IdHeader
	,'CRITERI_AGGIUDICAZIONE' as DSE_ID
	, isnull( c.Row , 0 ) as Row
	, 'ModalitaAnomalia_TEC' as DZT_Name
	,isnull( c.Value , ModalitaAnomalia_TEC ) as Value
	
	from document_microlotti_dettagli l
		inner join document_Bando v on l.idheader = v.idHeader 
		left outer join Document_Microlotti_DOC_Value c on c.idheader = l.id and c.DSE_ID = 'CRITERI_AGGIUDICAZIONE' and  c.DZT_Name = 'ModalitaAnomalia_TEC'
		




GO
