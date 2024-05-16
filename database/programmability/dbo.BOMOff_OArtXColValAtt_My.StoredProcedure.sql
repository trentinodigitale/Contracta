USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOMOff_OArtXColValAtt_My]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOMOff_OArtXColValAtt_My](@IdOff INT) AS
 SELECT  *
  FROM ValoriAttributi_Money
  WHERE IdVat IN (
   SELECT  OfferteArticoliXColonne.oacIdVat
    FROM OfferteArticoliXColonne
    INNER JOIN OfferteArticoli ON OfferteArticoli.IdOar = OfferteArticoliXColonne.oacIdOar
    WHERE (OfferteArticoli.oarIdOff = @IdOff))
GO
