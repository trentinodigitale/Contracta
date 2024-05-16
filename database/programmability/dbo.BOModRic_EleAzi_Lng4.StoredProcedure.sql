USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModRic_EleAzi_Lng4]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModRic_EleAzi_Lng4](@IdRic INT) AS
 SELECT  Aziende.IdAzi,
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
  aziSitoWeb AS aziWeb
 FROM Aziende
  LEFT OUTER JOIN DescsLng4 AS DescsLng4_Descrizione ON DescsLng4_Descrizione.IdDsc = Aziende.aziIdDscDescrizione
  LEFT OUTER JOIN DescsLng4 AS DescsLng4_FormaSoc ON DescsLng4_FormaSoc.IdDsc = Aziende.aziIdDscFormaSoc
 WHERE (Aziende.IdAzi IN (
  SELECT DISTINCT Articoli.artIdAzi
   FROM RicercheArticoli
   INNER JOIN Articoli ON Articoli.IdArt = RicercheArticoli.racIdArt
   WHERE RicercheArticoli.racIdRic = @IdRic ))
 ORDER BY Aziende.IdAzi
GO
