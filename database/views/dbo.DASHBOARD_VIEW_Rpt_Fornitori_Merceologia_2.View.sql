USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_Rpt_Fornitori_Merceologia_2]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[DASHBOARD_VIEW_Rpt_Fornitori_Merceologia_2] as 


	select ClasseIscriz,  Descrizione as ClasseMerceDesc ,  Descrizione as ClasseMerceDesc_Sort , AnnoMese as Periodo  , AnnoMese as Periodo_Sort , Territorio , Territorio as Territorio_Sort, 1 as Qta
		from DASHBOARD_VIEW_Rpt_Fornitori_Merceologia_sub


	--select ClasseIscriz,  Descrizione as ClasseMerceDesc ,  Descrizione as ClasseMerceDesc_Sort , AnnoMese as Periodo  , AnnoMese as Periodo_Sort , Territorio , Territorio as Territorio_Sort, COUNT( * )  as Qta
	--	from DASHBOARD_VIEW_Rpt_Fornitori_Merceologia_sub
	--	group by ClasseIscriz,  Descrizione  , AnnoMese , Territorio 

	--union aLL

	--select ClasseIscriz,  Descrizione as ClasseMerceDesc ,  Descrizione as ClasseMerceDesc_Sort , 'Totale' as Periodo  , 'Totale'as Periodo_Sort , Territorio , Territorio as Territorio_Sort, COUNT( * )  as Qta
	--	from DASHBOARD_VIEW_Rpt_Fornitori_Merceologia_sub
	--	group by ClasseIscriz,  Descrizione , Territorio 



GO
