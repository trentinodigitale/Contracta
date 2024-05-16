USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TempOff_ArtOff_Lng4]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[TempOff_ArtOff_Lng4] (@IdOff INT) AS
SELECT TempOfferteArticoli.oarIdArt AS IdArt, Articoli.artIdAzi, Articoli.artCspValue, Articoli.artCode, Articoli.artIdUms, 
        Aziende.aziRagioneSociale, DescsLng4.dscTesto AS artDesc, Articoli.artQMO AS artQMO
        FROM TempOfferteArticoli
 INNER JOIN Articoli ON Articoli.IdArt = TempOfferteArticoli.oarIdArt
 INNER JOIN Aziende ON Articoli.artIdAzi = Aziende.IdAzi
 INNER JOIN DescsLng4 ON Articoli.artIdDscDescrizione = DescsLng4.IdDsc
  WHERE (TempOfferteArticoli.oarIdOff = @IdOff)
GO
