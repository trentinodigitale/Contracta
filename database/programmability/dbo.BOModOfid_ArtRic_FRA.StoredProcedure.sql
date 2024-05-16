USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOfid_ArtRic_FRA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOModOfid_ArtRic_FRA] (@IdRic INT) AS
SELECT Articoli.IdArt, Articoli.artIdAzi, Articoli.artCspValue, Articoli.artCode, Articoli.artIdUms, 
       Aziende.aziRagioneSociale, DescsFRA.dscTesto AS artDesc, Articoli.artQMO AS artQMO
       FROM RicercheArticoli
       INNER JOIN Articoli ON RicercheArticoli.racIdArt = Articoli.IdArt
       INNER JOIN Aziende ON Articoli.artIdAzi = Aziende.IdAzi
       INNER JOIN DescsFRA ON Articoli.artIdDscDescrizione = DescsFRA.IdDsc       
       WHERE (RicercheArticoli.racIdRic = @IdRic) AND
  (RicercheArticoli.racSegnato = 1)
 ORDER BY RicercheArticoli.racIdArt
GO
