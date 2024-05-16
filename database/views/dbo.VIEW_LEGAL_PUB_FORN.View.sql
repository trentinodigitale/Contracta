USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_LEGAL_PUB_FORN]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VIEW_LEGAL_PUB_FORN] as

select idazi ,  
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
	 
	
	
	
from aziende with(nolock)
	LEFT OUTER JOIN DM_Attributi  AS DM_5 with(nolock) ON Aziende.IdAzi = DM_5.lnk AND DM_5.idApp = 1 AND DM_5.dztNome = 'CodiceFiscale'


GO
