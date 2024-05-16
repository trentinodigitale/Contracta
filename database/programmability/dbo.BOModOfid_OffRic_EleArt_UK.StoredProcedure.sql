USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOfid_OffRic_EleArt_UK]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOModOfid_OffRic_EleArt_UK] (@IdMdl INT) AS
SELECT Articoli.IdArt, Articoli.artIdAzi, Articoli.artCspValue, Articoli.artCode, Articoli.artIdUms, 
        Aziende.aziRagioneSociale, DescsUK.dscTesto AS artDesc, Articoli.artQMO AS artQMO
        FROM Offerte
 INNER JOIN OfferteArticoli ON Offerte.IdOff = OfferteArticoli.oarIdOff
 INNER JOIN Articoli ON Articoli.IdArt = OfferteArticoli.oarIdArt
 INNER JOIN Aziende ON Articoli.artIdAzi = Aziende.IdAzi
 INNER JOIN DescsUK ON Articoli.artIdDscDescrizione = DescsUK.IdDsc
  WHERE (Offerte.offIdMdl = @IdMdl AND offStato = 3)
GO
