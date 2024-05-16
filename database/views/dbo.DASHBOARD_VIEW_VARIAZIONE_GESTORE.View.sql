USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_VARIAZIONE_GESTORE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[DASHBOARD_VIEW_VARIAZIONE_GESTORE] as
	select 
		C.ID,
		C.Titolo,
		C.Protocollo,
		C.DataInvio,
		C.Idpfu,
		C.TipoDoc as OPEN_DOC_NAME
		,C.[StatoFunzionale]
		



		from CTL_DOC C
			inner join Document_Configurazione_Variazione_Gestore A on C.id = A.idheader
		where C.Statodoc='Sent' and c.tipoDoc = 'VARIAZIONE_GESTORE'





GO
