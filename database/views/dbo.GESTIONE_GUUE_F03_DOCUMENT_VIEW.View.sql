USE [AFLink_TND]
GO
/****** Object:  View [dbo].[GESTIONE_GUUE_F03_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[GESTIONE_GUUE_F03_DOCUMENT_VIEW] as 
select 
	C.*,
	value as Ambito
	--DC.DOC_Name,
	--DC.Ambito,
	--DC.Merceologia,
	--DescrizioneEstesa
	
	from ctl_doc C with(nolock)
		--inner join Document_Convenzione DC with (nolock) on C.linkeddoc=DC.id
		inner join ctl_doc S with (nolock) on C.linkeddoc=S.id
			left join ctl_doc_value  with (nolock) on idheader = C.id and dse_id='INFO_AGGIUNTIVE' and DZT_Name='ambito'


GO
