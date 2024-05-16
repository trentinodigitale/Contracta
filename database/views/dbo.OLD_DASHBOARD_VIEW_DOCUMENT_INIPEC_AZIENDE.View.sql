USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_DOCUMENT_INIPEC_AZIENDE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_DOCUMENT_INIPEC_AZIENDE]
AS

select
	a.idAzi as idRow,
	a.idHeader,
	a.codiceFiscale as aziCodiceFiscale,
	b.aziRagioneSociale,
	a.emailPEC as EMAIL,
	a.statoINIPEC as statoRichiestaINIPEC,
	a.descrizioneEsitoInipec as esito,
	'SCHEDA_ANAGRAFICA' as OPEN_DOC_NAME
	from Document_INIPEC a with (nolock)
		left Join Aziende b with (nolock) on a.idAzi = b.IdAzi

GO
