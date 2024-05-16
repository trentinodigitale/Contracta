USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_AZI_DOC_RTI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_DASHBOARD_VIEW_AZI_DOC_RTI] as
select distinct 
	idazi as indrow,  
	idazi as id,
    idazi as IdAziAusiliata,  
	idazi as IdAziConsorzio,  
	aziRagioneSociale,
	aziRagioneSociale as RagSocConsorzio,   
	aziRagioneSociale as RagSocAusiliata,
	idazi as IdAziRiferimento,
	aziRagioneSociale as RagSocRiferimento,
	aziindirizzoleg, 
	aziProvinciaLeg , 
	aziLocalitaLeg ,
	aziStatoLeg ,
	aziCAPLeg ,
	aziIdDscFormaSoc ,
	aziPartitaIVA ,
	azitelefono1,
	azifax,
	azie_mail,
    DM_5.vatValore_FT AS codicefiscaleConsorzio,
	DM_5.vatValore_FT AS codicefiscaleAusiliata

from aziende 
LEFT OUTER JOIN DM_Attributi AS DM_5 ON Aziende.IdAzi = DM_5.lnk AND DM_5.idApp = 1 AND DM_5.dztNome = 'codicefiscale'

where azivenditore > 0       and aziacquirente = 0    and azideleted=0 
		and substring( azifunzionalita , 239 , 1 ) = '1'

GO
