USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PARAMETRI_SEDUTA_VIRTUALE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[DASHBOARD_VIEW_PARAMETRI_SEDUTA_VIRTUALE] as
	select 
		C.ID,
		C.Titolo,
		C.Protocollo,
		C.DataInvio,
		C.Idpfu,
		C.TipoDoc as OPEN_DOC_NAME
		,C.[StatoFunzionale]
		,[Visualizza_Comunicazione]
		,[Singolo_Lotto]
		,[Lista_Lotti]
		,[Visibilita_Lotti]
		,[Visualizza_Dati_Amministrativi]
		,[Chiusura]
		,[Apertura]
		,[Visibilita]



		from CTL_DOC C
			inner join Document_Parametri_Sedute_Virtuali A on C.id = A.idheader
		where C.Statodoc='Sent' and c.tipoDoc = 'PARAMETRI_SEDUTA_VIRTUALE'




GO
