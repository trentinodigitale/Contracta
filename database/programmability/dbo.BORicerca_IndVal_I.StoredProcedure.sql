USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BORicerca_IndVal_I]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BORicerca_IndVal_I](@IdRic INT) AS
 SELECT Aziende.IdAzi, 
  ValoriIndicatori.IdVInd,
  DescsI.dscTesto AS vindIdDsc_Testo,
  ValoriIndicatori.vindValore,
  ValoriIndicatori.vindDI,
  ValoriIndicatori.vindDF 
 FROM Aziende
  INNER JOIN ValoriIndicatori ON ValoriIndicatori.vindIdAzi = Aziende.IdAzi
  LEFT OUTER JOIN DescsI ON DescsI.idDsc = ValoriIndicatori.vindIdDsc 
 WHERE (Aziende.IdAzi IN (
  SELECT DISTINCT Articoli.artIdAzi
   FROM RicercheArticoli
   INNER JOIN Articoli ON Articoli.IdArt = RicercheArticoli.racIdArt
   WHERE RicercheArticoli.racIdRic = @IdRic ))
 ORDER BY ValoriIndicatori.IdVInd
GO
