USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_DOCUMENTI_TEMPLATE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_DOCUMENTI_TEMPLATE] as
select 
		C.ID,
		C.Titolo,
		C.Protocollo,
		C.DataInvio,
		C.Idpfu,
		C.TipoDoc as OPEN_DOC_NAME ,
		c.StatoFunzionale , 
		C.Deleted , 
		C.JumpCheck


		from CTL_DOC C
		where  c.tipoDoc = 'TEMPLATE_REQUEST' and deleted = 0 



GO
