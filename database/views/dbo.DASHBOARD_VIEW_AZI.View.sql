USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_AZI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_AZI] as
select distinct   idazi ,  
	aziindirizzoleg, 
	aziRagioneSociale ,   
	aziProvinciaLeg , 
	aziLocalitaLeg ,
	aziStatoLeg ,
	aziCAPLeg ,
	aziIdDscFormaSoc ,
	aziPartitaIVA ,
	azitelefono1,
	azifax,
	azie_mail,
	DM_5.vatValore_FT AS codicefiscale
	
from aziende  with(nolock) 
LEFT OUTER JOIN DM_Attributi AS DM_5  with(nolock) ON Aziende.IdAzi = DM_5.lnk AND DM_5.idApp = 1 AND DM_5.dztNome = 'codicefiscale'

where azivenditore > 0       and aziacquirente = 0    and azideleted=0 and substring( azifunzionalita , 239 , 1 ) = '1'


GO
