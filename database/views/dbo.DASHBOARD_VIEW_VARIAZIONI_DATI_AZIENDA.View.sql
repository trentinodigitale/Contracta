USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_VARIAZIONI_DATI_AZIENDA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_VARIAZIONI_DATI_AZIENDA]
as
select 

	c.*
	,DataInvio as DataInvioDal
	,DataInvio as DataInvioAl
	,TipoDoc as OPEN_DOC_NAME
	,p.idpfu as owner
from 
	ctl_doc c
		left join aziende on Destinatario_Azi=idazi
		left join profiliutente p on pfuidazi=idazi

where 
	tipodoc='VARIAZIONE_DATI_AZIENDA' and deleted=0





GO
