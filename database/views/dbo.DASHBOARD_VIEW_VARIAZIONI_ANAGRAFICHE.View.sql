USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_VARIAZIONI_ANAGRAFICHE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_VARIAZIONI_ANAGRAFICHE]
as
select 

	c.*
	,DataInvio as DataInvioDal
	,DataInvio as DataInvioAl
	,TipoDoc as OPEN_DOC_NAME
	,p.idpfu as owner
from 
	ctl_doc c
		left join aziende on linkeddoc=idazi
		left join profiliutente p on pfuidazi=idazi

where 
	tipodoc='VARIAZIONE_ANAGRAFICA' and deleted=0



GO
