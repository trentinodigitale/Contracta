USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModRic_ArtRic_Lng3]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModRic_ArtRic_Lng3] (@IdRic INT) AS
SELECT Articoli.IdArt, Articoli.artIdAzi, Articoli.artCspValue, Articoli.artCode, Articoli.artIdUms, 
       Aziende.aziRagioneSociale, DescsLng3.dscTesto AS artDesc, Articoli.artQMO AS artQMO,
       Articoli.artSitoWeb AS artWeb
       FROM RicercheArticoli
       INNER JOIN Articoli ON RicercheArticoli.racIdArt = Articoli.IdArt
       INNER JOIN Aziende ON Articoli.artIdAzi = Aziende.IdAzi
       INNER JOIN DescsLng3 ON Articoli.artIdDscDescrizione = DescsLng3.IdDsc       
       WHERE (RicercheArticoli.racIdRic = @IdRic)
 ORDER BY RicercheArticoli.racIdArt
GO
