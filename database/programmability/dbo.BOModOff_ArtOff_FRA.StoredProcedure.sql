USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOff_ArtOff_FRA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOModOff_ArtOff_FRA] (@IdOff INT) AS
SELECT Articoli.IdArt, Articoli.artIdAzi, Articoli.artCspValue, Articoli.artCode, Articoli.artIdUms, 
        Aziende.aziRagioneSociale, DescsFRA.dscTesto AS artDesc, Articoli.artQMO AS artQMO
        FROM OfferteArticoli
 INNER JOIN Articoli ON Articoli.IdArt = OfferteArticoli.oarIdArt
 INNER JOIN Aziende ON Articoli.artIdAzi = Aziende.IdAzi
 INNER JOIN DescsFRA ON Articoli.artIdDscDescrizione = DescsFRA.IdDsc 
  WHERE (OfferteArticoli.oarIdOff = @IdOff)
GO
