USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_GESTIONE_INIZIATIVE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[DASHBOARD_VIEW_GESTIONE_INIZIATIVE] as 
	SELECT
		C.Id
		,EsitoRiga
		,StatoFunzionale
		,NumeroDocumento  --Id Inizativa
		,Descrizione as Titolo
		,Area_Organizzativa_Responsabile
		,Ruolo_DRCA
		,CategoriaDiSpesa
		,C.Deleted
		,P.UserRUP
	FROM ctl_doc C with(NOLOCK)
		left join Document_programmazione_iniziativa P on C.id = P.idheader
	WHERE TipoDoc = 'PROGRAMMAZIONE_INIZIATIVA'
		and StatoFunzionale  IN ('InLavorazione' ,'Annullato', 'InApprove', 'Approved', 'InRevised', 'Revised', 'InAnnullamento')
		and C.Deleted <> 1

GO
