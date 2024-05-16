USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PARAMETRI_CONVENZIONI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE view [dbo].[DASHBOARD_VIEW_PARAMETRI_CONVENZIONI] as
select 
		C.ID,
		C.Titolo,
		C.Protocollo,
		C.DataInvio,
		C.Idpfu,
		C.TipoDoc as OPEN_DOC_NAME ,
		c.StatoFunzionale , 
		C.Deleted

		from CTL_DOC C
		where C.Statodoc='Sent' and c.tipoDoc = 'PARAMETRI_CONVENZIONE' 
GO
