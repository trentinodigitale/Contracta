USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_MASTER_PROGRAMMAZIONE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view [dbo].[VIEW_MASTER_PROGRAMMAZIONE] as 
	SELECT
		C.Id
		,C.StatoFunzionale
		,C.NumeroDocumento  --Id Inizativa
		,P.Descrizione as Titolo
		,P.Area_Organizzativa_Responsabile
		,P.Ruolo_DRCA
		,P.CategoriaDiSpesa
		,P.Trimestre_Di_Indizione
		,P.Anno_Previsto_Di_Indizione
		,P.Trimestre_Di_Indizione_PrimaAgg
		,P.Anno_Previsto_Agg
		,P.Anno_Previsto_Attivazione
		,isnull('###' + cast(P.Anno_Previsto_Attivazione as varchar),'') + isnull('###' + cast(P.Anno_Previsto_Agg as varchar),'') + isnull('###' + cast(P.Anno_Previsto_Di_Indizione as varchar),'') as Anno
		,C.Deleted
	FROM ctl_doc C with(NOLOCK)
		left join Document_programmazione_iniziativa P on C.id = P.idheader
	WHERE TipoDoc = 'PROGRAMMAZIONE_INIZIATIVA'
		and StatoFunzionale  IN ('Approved', 'Revised')
		and C.Deleted <> 1

GO
