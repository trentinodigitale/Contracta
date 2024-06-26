USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOMOfid_OR_OArtXColValAtt_NVC]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOMOfid_OR_OArtXColValAtt_NVC] (@IdMdl INT) AS
 SELECT  *
  FROM ValoriAttributi_Nvarchar
  WHERE IdVat IN (
   SELECT  OfferteArticoliXColonne.oacIdVat
    FROM OfferteArticoliXColonne
    INNER JOIN OfferteArticoli ON OfferteArticoli.IdOar = OfferteArticoliXColonne.oacIdOar
    INNER JOIN Offerte ON OfferteArticoli.oarIdOff = Offerte.IdOff
    WHERE (Offerte.offIdMdl = @IdMdl AND Offerte.offStato = 3))
GO
