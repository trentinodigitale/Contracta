USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_TED_Aggiudicazione_sez_5]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[Document_TED_Aggiudicazione_sez_5] as
select 
	D.*,
	CT.Note
	from Document_TED_Aggiudicazione D with(nolock)
		inner join ctl_doc CT with(nolock) on CT.id=D.idHeader 
GO
