USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ExtendedDomain_BDG_Fornitori]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[ExtendedDomain_BDG_Fornitori] as
	select distinct cast( idazi as VARCHAR )  as  DMV_Cod
	 , aziRagioneSociale as DMV_DescML
	 , idazi as ID
	 , IdAzi 
     , aziragionesociale 
	 , '' as aziiddscformasoc
     , aziPartitaIVA
     , DM_1.vatvalore_ft     AS codicefiscale
	 , DM_2.vatvalore_ft     AS CARBelongTo
	 , DM_3.vatValore_FT AS cancellatodiufficio
     , aziIndirizzoLeg + ' - ' + azilocalitaleg + ' - ' + aziStatoleg  AS Indirizzo
     , DM_4.vatvalore_ft as InseritoDiUfficio
	
  FROM Aziende 

  LEFT OUTER JOIN DM_Attributi AS DM_1 ON Aziende.IdAzi = DM_1.lnk AND DM_1.idApp = 1 AND DM_1.dztNome = 'codicefiscale' 
  LEFT OUTER JOIN DM_Attributi AS DM_2 ON Aziende.IdAzi = DM_2.lnk AND DM_2.idApp = 1 AND DM_2.dztNome = 'carbelongto'
  LEFT OUTER JOIN DM_Attributi AS DM_3 ON Aziende.IdAzi = DM_3.lnk AND DM_3.idApp = 1 AND DM_3.dztNome = 'cancellatodiufficio'
  LEFT OUTER JOIN DM_Attributi AS DM_4 ON Aziende.IdAzi = DM_4.lnk AND DM_4.idApp = 1 AND DM_4.dztNome = 'InseritoDiUfficio'
   WHERE 
    aziDeleted = 0 and azivenditore > 0  and aziacquirente = 0
   


GO
