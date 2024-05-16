USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_CTL_DOC_VIEW_COMMISSIONE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_CTL_DOC_VIEW_COMMISSIONE] as 

select 
	c.*
	, c1.value as Conformita
	, c2.value as CriterioAggiudicazioneGara
	from 
		ctl_doc c
			left join ctl_doc_value c1 on c1.IdHeader=id and c1.dse_id='TESTATA' and c1.DZT_Name='Conformita'
			left join ctl_doc_value c2 on c2.IdHeader=id and c2.dse_id='TESTATA' and c2.DZT_Name='CriterioAggiudicazioneGara'
		where tipodoc='COMMISSIONE_PDA'




GO
