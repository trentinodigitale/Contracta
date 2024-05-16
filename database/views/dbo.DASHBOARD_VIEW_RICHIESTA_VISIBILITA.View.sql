USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_RICHIESTA_VISIBILITA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[DASHBOARD_VIEW_RICHIESTA_VISIBILITA]
as
select 

	*
	,DataInvio as DataInvioDal
	,DataInvio as DataInvioAl
	,TipoDoc as OPEN_DOC_NAME
	
from 
	ctl_doc
		left join aziende on linkeddoc=idazi

where 
	tipodoc='RICHIESTA_VISIBILITA' and deleted=0



GO
