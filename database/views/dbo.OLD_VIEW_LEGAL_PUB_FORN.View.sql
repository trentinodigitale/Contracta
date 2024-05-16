USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_LEGAL_PUB_FORN]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_VIEW_LEGAL_PUB_FORN] as
select distinct   idazi ,  
	aziindirizzoleg, 
	aziragionesociale ,   
	aziprovincialeg , 
	azilocalitaleg ,
	azistatoleg ,
	azicapleg ,
	aziiddscformasoc ,
	azipartitaiva ,
	case when azitelefono1 is null then ''
	else  azitelefono1
	end  AS azitelefono1 ,
	case when azifax is null then ''
	else  azifax
	end  AS azifax ,
	azie_mail,
	case when azisitoweb is null then ''
	else  azisitoweb
	end  AS azisitoweb, 
	       
	case when DM_5.vatValore_FT is null then ''
	   else  DM_5.vatValore_FT
	end  AS codicefiscale
	 
	
	
	
from aziende 
LEFT OUTER JOIN DM_Attributi AS DM_5 ON Aziende.IdAzi = DM_5.lnk AND DM_5.idApp = 1 AND DM_5.dztNome = 'CodiceFiscale'

where 
--azivenditore > 0       and aziacquirente = 0    and 
azideleted=0
GO
