USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TempRicercheAzi_Dett_Lng4]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[TempRicercheAzi_Dett_Lng4] AS
SELECT Aziende.IdAzi,
       aziRagioneSociale, 
       DescsLng4_FormaSoc.dscTesto AS aziFormaSoc,
       DescsLng4_Descrizione.dscTesto AS aziDescrizione,
       aziE_Mail,
       aziPartitaIVA,
       aziIndirizzoLeg,
       aziLocalitaLeg,
       aziProspect,
       aziStatoLeg,
       aziCAPLeg,
       aziPrefisso,
       aziTelefono1,
       aziFAX,
       aziAtvAtecord,
       aziGphValueOper,
       Web.aziWeb,
       aziProvinciaLeg
  FROM Aziende, DescsLng4 AS DescsLng4_FormaSoc, DescsLng4 AS DescsLng4_Descrizione, AziWeb AS Web
 WHERE DescsLng4_Descrizione.IdDsc = Aziende.aziIdDscDescrizione
   AND DescsLng4_FormaSoc.IdDsc = Aziende.aziIdDscFormaSoc
   AND Aziende.IdAzi = Web.IdAzi
   AND Aziende.IdAzi IN (SELECT DISTINCT Articoli.artIdAzi
                           FROM TempRicercheArticoli, Articoli
                          WHERE Articoli.IdArt = TempRicercheArticoli.racIdArt)
UNION ALL
SELECT Aziende.IdAzi,
       aziRagioneSociale, 
       DescsLng4_FormaSoc.dscTesto AS aziFormaSoc,
       NULL AS aziDescrizione,
       aziE_Mail,
       aziPartitaIVA,
       aziIndirizzoLeg,
       aziLocalitaLeg,
       aziProspect,
       aziStatoLeg,
       aziCAPLeg,
       aziPrefisso,
       aziTelefono1,
       aziFAX,
       aziAtvAtecord,
       aziGphValueOper,
       Web.aziWeb,
       aziProvinciaLeg
  FROM Aziende, DescsLng4 AS DescsLng4_FormaSoc, AziWeb AS Web
 WHERE DescsLng4_FormaSoc.IdDsc = Aziende.aziIdDscFormaSoc
   AND Aziende.IdAzi = Web.IdAzi
   AND Aziende.aziIdDscDescrizione IS NULL
   AND Aziende.IdAzi IN (SELECT DISTINCT Articoli.artIdAzi
                           FROM TempRicercheArticoli, Articoli
                          WHERE Articoli.IdArt = TempRicercheArticoli.racIdArt)
UNION ALL
SELECT Aziende.IdAzi,
       aziRagioneSociale, 
       DescsLng4_FormaSoc.dscTesto AS aziFormaSoc,
       DescsLng4_Descrizione.dscTesto AS aziDescrizione,
       aziE_Mail,
       aziPartitaIVA,
       aziIndirizzoLeg,
       aziLocalitaLeg,
       aziProspect,
       aziStatoLeg,
       aziCAPLeg,
       aziPrefisso,
       aziTelefono1,
       aziFAX,
       aziAtvAtecord,
       aziGphValueOper,
       NULL AS aziWeb,
       aziProvinciaLeg
  FROM Aziende, DescsLng4 AS DescsLng4_FormaSoc, DescsLng4 AS DescsLng4_Descrizione
 WHERE DescsLng4_Descrizione.IdDsc = Aziende.aziIdDscDescrizione
   AND DescsLng4_FormaSoc.IdDsc = Aziende.aziIdDscFormaSoc
   AND Aziende.IdAzi NOT IN (SELECT IdAzi FROM AziWeb)
   AND Aziende.IdAzi IN (SELECT DISTINCT Articoli.artIdAzi
                           FROM TempRicercheArticoli, Articoli
                          WHERE Articoli.IdArt = TempRicercheArticoli.racIdArt)
UNION ALL
SELECT Aziende.IdAzi,
       aziRagioneSociale, 
       DescsLng4_FormaSoc.dscTesto AS aziFormaSoc,
       NULL AS aziDescrizione,
       aziE_Mail,
       aziPartitaIVA,
       aziIndirizzoLeg,
       aziLocalitaLeg,
       aziProspect,
       aziStatoLeg,
       aziCAPLeg,
       aziPrefisso,
       aziTelefono1,
       aziFAX,
       aziAtvAtecord,
       aziGphValueOper,
       NULL AS aziWeb,
       aziProvinciaLeg
  FROM Aziende, DescsLng4 AS DescsLng4_FormaSoc
 WHERE DescsLng4_FormaSoc.IdDsc = Aziende.aziIdDscFormaSoc
   AND Aziende.IdAzi NOT IN (SELECT IdAzi FROM AziWeb)
   AND Aziende.aziIdDscDescrizione IS NULL
   AND Aziende.IdAzi IN (SELECT DISTINCT Articoli.artIdAzi
                           FROM TempRicercheArticoli, Articoli
                          WHERE Articoli.IdArt = TempRicercheArticoli.racIdArt)
GO
