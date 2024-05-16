USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_TEMPLATE_GARE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_TEMPLATE_GARE] 

as

--template per bandi procedure aperte 
select distinct TMF.idmsg,idpfu,TMF.name,TMF.ProceduraGara,TMF.tipoappalto,TMF.tipobando 
from 
	tab_utenti_messaggi TUM , tab_messaggi_fields TMF --, funzionalitautente FU
	, profiliutente
where 
	TUM.umidmsg=TMF.idmsg
	and TUM.umidpfu=-30
	--and FU.fnzupos = 4
	and proceduragara=15476 
	and substring(pfufunzionalita,4,1)='1'
	and pfuprofili not like '%S%'	
	and idpfu>0

union all

--template per bandi procedure ristrette
select distinct TMF.idmsg,idpfu,TMF.name,TMF.ProceduraGara,TMF.tipoappalto,TMF.tipobando 
from 
	tab_utenti_messaggi TUM , tab_messaggi_fields TMF --, funzionalitautente FU
	, profiliutente
where 
	TUM.umidmsg=TMF.idmsg
	and TUM.umidpfu=-30
	--and FU.fnzupos = 22
	and proceduragara=15477 
	and substring(pfufunzionalita,22,1)='1'
	and pfuprofili not like '%S%'	
	and idpfu>0



GO
