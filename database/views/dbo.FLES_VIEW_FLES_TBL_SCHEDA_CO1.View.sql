USE [AFLink_TND]
GO
/****** Object:  View [dbo].[FLES_VIEW_FLES_TBL_SCHEDA_CO1]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE     VIEW [dbo].[FLES_VIEW_FLES_TBL_SCHEDA_CO1] AS
	select
		UUID,
		(select pfuNome from DASHBOARD_VIEW_UTENTI dshViewUte where dshViewUte.IdPfu = IDPFU_INVIO) as utente,  --OK > (Utente che invia),
		(select pfuNome from DASHBOARD_VIEW_UTENTI dshViewUte where dshViewUte.IdPfu = IDPFU_BOZZA) as compilatore_co1,  --OK > (Compilatore),
		IDDOC,
		IDROW_PCP_SCHEDE,
		REGISTRO_SISTEMA,
		CIG,
		ID_CONTRATTO,
		ID_APPALTO,
		STATO_FUNZIONALE AS esito,
		DATA_INVIO AS dataInvioScheda,
		DATA_ULTIMA_MODIFICA,
		STATO_BOZZA as STATO_BOZZA,
		DATA_ULTIMAZIONE_PRESTAZIONE as dataUltimazionePrestazione,
		DATA_STIPULA_CONTRATTO,
		DATA_ESECUTIVITA,
		CAUSA_INTERRUZIONE_ANTICIPATA,
		DATA_INTERRUZIONE_ANTICIPATA,
		MOTIVI_RISOLUZIONE,
		ONERI_ECONOMICI_RISOLUZIONE_RECESSO,
		IMPORTO,
		INCAMERATA_POLIZZA as incamerataPolizza,
		NUM_INFORTUNI as numInfortuni,
		DI_CUI_POSTUMI_PERMANENTI as diCuiPostumiPermanenti,
		DI_CUI_MORTALI as diCuiMortali
		from FLES_TABLE_SCHEDA_CO1
GO
