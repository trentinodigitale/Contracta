USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PARAMETRI_CONTROLLO_INIPEC]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[DASHBOARD_VIEW_PARAMETRI_CONTROLLO_INIPEC]
AS
SELECT      Id,
			IdPfu,
			Protocollo,
			DataInvio,
			StatoFunzionale,
			'PARAMETRI_CONTROLLO_INIPEC' as OPEN_DOC_NAME
FROM        CTL_DOC
with (nolock)
where TipoDoc = 'PARAMETRI_CONTROLLO_INIPEC'
	and Deleted = 0

GO
