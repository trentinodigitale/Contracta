USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VIEW_RIEPILOGO_FINALE_PDA_XLSX]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD2_VIEW_RIEPILOGO_FINALE_PDA_XLSX] AS
	select idPDA as IdHeader,NumeroLotto, isnull(ml.ML_Description, vals.DMV_DescML) as CampoTesto_1 ,aziRagioneSociale, isnull(ml2.ML_Description, vals2.DMV_DescML) as CampoTesto_2,Graduatoria, ValoreOfferta, PunteggioTecnico,PunteggioEconomico,ValoreImportoLotto,Sorteggio,cast( numriga as int) as numriga, 'BANDO_GARA' as tipodoc, PrzBaseAsta, PercentualeRibasso, Ribasso,
	Voce,statoRiga,InversioneBuste
		from PDA_DRILL_MICROLOTTO_LISTA_VIEW  

				left join LIB_DomainValues vals with(nolock) on vals.DMV_DM_ID = 'StatoRiga' and vals.DMV_Cod = StatoRiga
				left outer join dbo.LIB_Multilinguismo ml with(nolock) ON vals.DMV_DescML = ml.ML_KEY and ml.ML_LNG = 'I'

				left join LIB_DomainValues vals2 with(nolock) on vals2.DMV_DM_ID = 'Posizione' and vals2.DMV_Cod = Posizione
				left outer join dbo.LIB_Multilinguismo ml2 with(nolock) ON vals2.DMV_DescML = ml2.ML_KEY and ml2.ML_LNG = 'I'

		where Voce = 0 and statoRiga <> 'escluso'  
GO
