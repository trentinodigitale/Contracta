USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModRic_EleAzi_UK]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOModRic_EleAzi_UK](@IdRic INT) AS
 SELECT  Aziende.IdAzi,
  aziRagioneSociale, 
  DescsUK_FormaSoc.dscTesto AS aziFormaSoc,
  DescsUK_Descrizione.dscTesto AS aziDescrizione,
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
  aziSitoWeb AS aziWeb
 FROM Aziende
  LEFT OUTER JOIN DescsUK AS DescsUK_Descrizione ON DescsUK_Descrizione.IdDsc = Aziende.aziIdDscDescrizione
  LEFT OUTER JOIN DescsUK AS DescsUK_FormaSoc ON DescsUK_FormaSoc.IdDsc = Aziende.aziIdDscFormaSoc
 WHERE (Aziende.IdAzi IN (
  SELECT DISTINCT Articoli.artIdAzi
   FROM RicercheArticoli
   INNER JOIN Articoli ON Articoli.IdArt = RicercheArticoli.racIdArt
   WHERE RicercheArticoli.racIdRic = @IdRic ))
 ORDER BY Aziende.IdAzi
GO
