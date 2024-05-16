USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_GESTIONE_GUUE_F03_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_GESTIONE_GUUE_F03_DOCUMENT_VIEW] as 
select 
	C.*--,
	--DC.DOC_Name,
	--DC.Ambito,
	--DC.Merceologia,
	--DescrizioneEstesa
	from ctl_doc C with(nolock)
		--inner join Document_Convenzione DC with (nolock) on C.linkeddoc=DC.id
		inner join ctl_doc S with (nolock) on C.linkeddoc=S.id
	


GO
