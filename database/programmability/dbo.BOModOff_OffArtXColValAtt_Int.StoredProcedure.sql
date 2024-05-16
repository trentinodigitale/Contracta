USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOff_OffArtXColValAtt_Int]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModOff_OffArtXColValAtt_Int](@IdOff INT) AS
 SELECT  *
  FROM ValoriAttributi_Int
  WHERE IdVat IN (
   SELECT  OfferteArticoliXColonne.oacIdVat
    FROM OfferteArticoliXColonne
    INNER JOIN OfferteArticoli ON OfferteArticoli.IdOar = OfferteArticoliXColonne.oacIdOar
    WHERE (OfferteArticoli.oarIdOff = @IdOff))
GO
