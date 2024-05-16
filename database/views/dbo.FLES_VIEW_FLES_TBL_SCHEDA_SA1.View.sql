USE [AFLink_TND]
GO
/****** Object:  View [dbo].[FLES_VIEW_FLES_TBL_SCHEDA_SA1]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE     VIEW [dbo].[FLES_VIEW_FLES_TBL_SCHEDA_SA1] AS
	select
		UUID,
		(select pfuNome from DASHBOARD_VIEW_UTENTI dshViewUte where dshViewUte.IdPfu = IDPFU_INVIO) as utente,  --OK > (Utente in carico  Frontend Dettaglio),
		(select pfuNome from DASHBOARD_VIEW_UTENTI dshViewUte where dshViewUte.IdPfu = IDPFU_BOZZA) as compilatore_SA1,  --OK > (Compilatore  Frontend Dettaglio),
		IDDOC,
		DENOMINAZIONE_AVANZAMENTO as denominazioneAvanzamento,
		MODALITA_PAGAMENTO as modalitaPagamento,
		DATA_AVANZAMENTO as dataAvanzamento,
		AVANZAMENTO as avanzamento,
		IMPORTO_CUMULATO as importoCumulato,
		ULTIMO_IMPORTO_COMUNICATO,
		IDROW_PCP_SCHEDE,
		REGISTRO_SISTEMA,
		STATO_FUNZIONALE AS esito,
		DATA_INVIO AS dataInvioScheda,
		DATA_ULTIMA_MODIFICA,
		STATO_BOZZA
	from FLES_TABLE_SCHEDA_SA1
GO
