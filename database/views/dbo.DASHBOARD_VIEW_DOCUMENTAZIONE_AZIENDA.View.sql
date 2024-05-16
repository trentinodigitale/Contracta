USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_DOCUMENTAZIONE_AZIENDA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_DOCUMENTAZIONE_AZIENDA] AS
	select 
	C.ID as ID,
	C.StatoDoc ,
	C.DataInvio,
	C.Titolo,
	C.Body,
	NumMesiVal,
	Albo,
	'ANAG_DOCUMENTAZIONE' as OPEN_DOC_NAME,
	StatoFunzionale
	, ContestoUsoDoc
	
	from CTL_DOC C
	left join Document_Anag_documentazione on C.ID=Document_Anag_documentazione.Idheader
	where C.deleted=0 and C.TipoDoc='ANAG_DOCUMENTAZIONE'



GO
