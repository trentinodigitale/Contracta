USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TempOff_ArtOff_E]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[TempOff_ArtOff_E] (@IdOff INT) AS
SELECT TempOfferteArticoli.oarIdArt AS IdArt, Articoli.artIdAzi, Articoli.artCspValue, Articoli.artCode, Articoli.artIdUms, 
        Aziende.aziRagioneSociale, DescsE.dscTesto AS artDesc, Articoli.artQMO AS artQMO
        FROM TempOfferteArticoli
 INNER JOIN Articoli ON Articoli.IdArt = TempOfferteArticoli.oarIdArt
 INNER JOIN Aziende ON Articoli.artIdAzi = Aziende.IdAzi
 INNER JOIN DescsE ON Articoli.artIdDscDescrizione = DescsE.IdDsc
  WHERE (TempOfferteArticoli.oarIdOff = @IdOff)
GO
