USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOMOfid_OR_OffArtXColonne]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOMOfid_OR_OffArtXColonne] (@IdMdl INT) AS
 SELECT OfferteArticoliXColonne.*
 FROM OfferteArticoliXColonne
 WHERE OfferteArticoliXColonne.oacIdOar IN
  (SELECT OfferteArticoli.IdOar
    FROM OfferteArticoli
    INNER JOIN Offerte ON OfferteArticoli.oarIdOff = Offerte.IdOff
    WHERE Offerte.offIdMdl = @IdMdl AND Offerte.offStato = 3)
GO
