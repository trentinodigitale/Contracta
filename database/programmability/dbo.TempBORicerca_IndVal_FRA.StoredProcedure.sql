USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TempBORicerca_IndVal_FRA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TempBORicerca_IndVal_FRA](@IdRic INT) AS
 SELECT Aziende.IdAzi, 
  ValoriIndicatori.IdVInd,
  DescsFRA.dscTesto AS vindIdDsc_Testo,
  ValoriIndicatori.vindValore,
  ValoriIndicatori.vindDI,
  ValoriIndicatori.vindDF 
 FROM Aziende
  INNER JOIN ValoriIndicatori ON ValoriIndicatori.vindIdAzi = Aziende.IdAzi
  LEFT OUTER JOIN DescsFRA ON DescsFRA.idDsc = ValoriIndicatori.vindIdDsc 
 WHERE (Aziende.IdAzi IN (
  SELECT DISTINCT Articoli.artIdAzi
   FROM TempRicercheArticoli
   INNER JOIN Articoli ON Articoli.IdArt = TempRicercheArticoli.racIdArt
   WHERE TempRicercheArticoli.racIdRic = @IdRic ))
 ORDER BY ValoriIndicatori.IdVInd
GO
