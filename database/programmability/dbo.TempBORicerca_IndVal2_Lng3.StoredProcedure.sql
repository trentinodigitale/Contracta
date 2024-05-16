USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TempBORicerca_IndVal2_Lng3]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[TempBORicerca_IndVal2_Lng3](@IdRic INT) AS
 SELECT Aziende.IdAzi, 
  ValoriIndicatori.IdVInd,
  DescsLng3.dscTesto AS vindIdDsc_Testo,
  ValoriIndicatori.vindValore,
  ValoriIndicatori.vindDI,
  ValoriIndicatori.vindDF 
 FROM Aziende
  INNER JOIN ValoriIndicatori ON ValoriIndicatori.vindIdAzi = Aziende.IdAzi
  LEFT OUTER JOIN DescsLng3 ON DescsLng3.idDsc = ValoriIndicatori.vindIdDsc 
 WHERE (Aziende.IdAzi IN ( SELECT DISTINCT razIdAzi FROM #TempRicercheAziende))
 ORDER BY ValoriIndicatori.IdVInd
GO
