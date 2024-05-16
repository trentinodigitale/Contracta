USE [AFLink_TND]
GO
/****** Object:  View [dbo].[FLES_VIEW_SERVICES_INTEGRATION_REQUEST]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE     VIEW [dbo].[FLES_VIEW_SERVICES_INTEGRATION_REQUEST] AS
	select
		idRow,
		idRichiesta,
		(select pfuNome from DASHBOARD_VIEW_UTENTI dshViewUte where dshViewUte.IdPfu = srvIntr.idPfu) as Utente,  --OK > (Utente in carico  Frontend Dettaglio),
		integrazione,
        operazioneRichiesta,
        statoRichiesta Esito,
        datoRichiesto as Scheda,
        msgError,
        numRetry,
        inputWS as DettaglioScheda,
        outputWS as DettaglioEsito,
        isOld,
        dateIn as DataInvio,
        DataExecuted,
        DataFinalizza,
        idPfu,
        idAzi,
        InOut	
	from Services_Integration_Request srvIntr

GO
