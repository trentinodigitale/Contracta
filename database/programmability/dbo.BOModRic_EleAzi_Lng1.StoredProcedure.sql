USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModRic_EleAzi_Lng1]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModRic_EleAzi_Lng1](@IdRic INT) AS
 SELECT  Aziende.IdAzi,
  aziRagioneSociale, 
  DescsLng1_FormaSoc.dscTesto AS aziFormaSoc,
  DescsLng1_Descrizione.dscTesto AS aziDescrizione,
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
  LEFT OUTER JOIN DescsLng1 AS DescsLng1_Descrizione ON DescsLng1_Descrizione.IdDsc = Aziende.aziIdDscDescrizione
  LEFT OUTER JOIN DescsLng1 AS DescsLng1_FormaSoc ON DescsLng1_FormaSoc.IdDsc = Aziende.aziIdDscFormaSoc
 WHERE (Aziende.IdAzi IN (
  SELECT DISTINCT Articoli.artIdAzi
   FROM RicercheArticoli
   INNER JOIN Articoli ON Articoli.IdArt = RicercheArticoli.racIdArt
   WHERE RicercheArticoli.racIdRic = @IdRic ))
 ORDER BY Aziende.IdAzi
GO
