USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TempBORicerca_IndVal2_UK]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[TempBORicerca_IndVal2_UK](@IdRic INT) AS
 SELECT Aziende.IdAzi, 
  ValoriIndicatori.IdVInd,
  DescsUK.dscTesto AS vindIdDsc_Testo,
  ValoriIndicatori.vindValore,
  ValoriIndicatori.vindDI,
  ValoriIndicatori.vindDF 
 FROM Aziende
  INNER JOIN ValoriIndicatori ON ValoriIndicatori.vindIdAzi = Aziende.IdAzi
  LEFT OUTER JOIN DescsUK ON DescsUK.idDsc = ValoriIndicatori.vindIdDsc 
 WHERE (Aziende.IdAzi IN ( SELECT DISTINCT razIdAzi FROM #TempRicercheAziende))
 ORDER BY ValoriIndicatori.IdVInd
GO
