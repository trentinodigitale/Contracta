USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PARAMETRI_ALBO_PROF]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_PARAMETRI_ALBO_PROF] as
	select 
		C.ID,
		C.Titolo,
		C.Protocollo,
		C.DataInvio,
		C.Idpfu,
		C.TipoDoc as OPEN_DOC_NAME ,

		NumMesiScadenza ,
		Sollecito ,
		NumPeriodiFreqPrimaria ,
		FreqPrimaria ,
		FreqSecondaria ,
		NumMaxPerConferma,
		c.StatoFunzionale , 
		a.Deleted

		from CTL_DOC C
			inner join Document_Parametri_Abilitazioni A on C.id = A.idheader
		where C.Statodoc='Sent' and c.tipoDoc = 'PARAMETRI_ALBO_PROF'






GO
