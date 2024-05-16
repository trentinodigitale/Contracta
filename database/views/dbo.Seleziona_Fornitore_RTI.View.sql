USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Seleziona_Fornitore_RTI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[Seleziona_Fornitore_RTI] as
select distinct 
	idazi as indrow,  
	idazi,
	aziRagioneSociale as RagSoc,
	aziindirizzoleg as indirizzoleg, 
	aziProvinciaLeg as ProvinciaLeg, 
	aziLocalitaLeg as LocalitaLeg,
	DM_5.vatValore_FT AS codicefiscale

from aziende 
LEFT OUTER JOIN DM_Attributi AS DM_5 ON Aziende.IdAzi = DM_5.lnk AND DM_5.idApp = 1 AND DM_5.dztNome = 'codicefiscale'

where azivenditore > 0       and aziacquirente = 0    and azideleted=0 
		and substring( azifunzionalita , 239 , 1 ) = '1'
GO
