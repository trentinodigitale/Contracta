USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOfid_ArtRic_Lng4]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModOfid_ArtRic_Lng4] (@IdRic INT) AS
SELECT Articoli.IdArt, Articoli.artIdAzi, Articoli.artCspValue, Articoli.artCode, Articoli.artIdUms, 
       Aziende.aziRagioneSociale, DescsLng4.dscTesto AS artDesc, Articoli.artQMO AS artQMO
       FROM RicercheArticoli
       INNER JOIN Articoli ON RicercheArticoli.racIdArt = Articoli.IdArt
       INNER JOIN Aziende ON Articoli.artIdAzi = Aziende.IdAzi
       INNER JOIN DescsLng4 ON Articoli.artIdDscDescrizione = DescsLng4.IdDsc       
       WHERE (RicercheArticoli.racIdRic = @IdRic) AND
  (RicercheArticoli.racSegnato = 1)
 ORDER BY RicercheArticoli.racIdArt
GO
