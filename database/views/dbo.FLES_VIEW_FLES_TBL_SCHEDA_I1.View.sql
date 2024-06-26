USE [AFLink_TND]
GO
/****** Object:  View [dbo].[FLES_VIEW_FLES_TBL_SCHEDA_I1]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE     VIEW [dbo].[FLES_VIEW_FLES_TBL_SCHEDA_I1] AS
	select
		UUID,
		(select pfuNome from DASHBOARD_VIEW_UTENTI dshViewUte where dshViewUte.IdPfu = IDPFU_INVIO) as inviatore,  --OK > (Utente in carico  Frontend Dettaglio),
		(select pfuNome from DASHBOARD_VIEW_UTENTI dshViewUte where dshViewUte.IdPfu = IDPFU_BOZZA) as compilatore_I1,  --OK > (Compilatore  Frontend Dettaglio),
		IDDOC,
		DATA_FINE_PREVISTA,
		DATA_EFFETTIVO_INIZIO,
		CONSEGNA_SOTTO_RISERVA,
		IDROW_PCP_SCHEDE,
		REGISTRO_SISTEMA,
		STATO_FUNZIONALE AS STATO_FUNZIONALE_I1,
		DATA_INVIO AS DATA_INVIO_I1,
		DATA_ULTIMA_MODIFICA,
		STATO_BOZZA
	from FLES_TABLE_SCHEDA_I1
GO
