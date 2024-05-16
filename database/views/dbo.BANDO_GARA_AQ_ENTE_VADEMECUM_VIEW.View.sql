USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_GARA_AQ_ENTE_VADEMECUM_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BANDO_GARA_AQ_ENTE_VADEMECUM_VIEW] AS
select distinct
	D.id as IDheader
	,ALLEGATI.Descrizione
	,ALLEGATI.Allegato
	,ISNULL(ALLEGATI.idrow,0) aS idrow
	from DASHBOARD_VIEW_ELENCO_AQ D
		inner join CTL_DOC C with(nolock) on C.LinkedDoc=D.id and C.TipoDoc='ATTIVA_AQ' and C.StatoFunzionale='Confermato'
		inner join CTL_DOC_ALLEGATI ALLEGATI with(nolock) on ALLEGATI.idHeader=C.id
GO
