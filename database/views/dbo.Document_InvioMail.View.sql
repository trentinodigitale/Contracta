USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_InvioMail]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[Document_InvioMail] AS
SELECT aziragionesociale
     , pfue_mail 
     , IdPfu 
     , IdAzi 
     , mpaDeleted AS StatoAzienda
     , aziIdDscFormaSoc AS FormaGiuridica
     , aziPartitaIVA 
     , aziIndirizzoLeg AS Indirizzo
     , aziLocalitaLeg
     , aziProvinciaLeg
     , aziStatoLeg AS Stato
     , aziCAPLeg
     , aziTelefono1
     , aziTelefono2
     , aziFAX
     , vatValore_FT AS CodiceFiscale
  FROM Aziende
     , ProfiliUtente 
     , MPAziende
     , DM_Attributi
     , MPMailCensimento
 WHERE IdAzi = pfuIdAzi
   AND aziDeleted = 0
   AND pfuDeleted = 0
   AND IdAzi <> 35152001
   AND mpaIdAzi = IdAzi
   AND mpaVenditore = 2
   AND IdApp = 1
   AND dztNome = 'CodiceFiscale'
   AND lnk = IdAzi
   AND IdAzi = mpmcIdAzi
   AND SUBSTRING(pfuOpzioni, 6, 1) = '0'


GO
