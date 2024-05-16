USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TempOff_OffArtXColValAtt_Int]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[TempOff_OffArtXColValAtt_Int](@IdOff INT)
with recompile
 AS
 SELECT  *
  FROM TempValoriAttributi_Int
  WHERE IdVat IN (
   SELECT  TempOfferteArticoliXColonne.oacIdVat
    FROM TempOfferteArticoliXColonne
    INNER JOIN TempOfferteArticoli ON TempOfferteArticoli.IdOar = TempOfferteArticoliXColonne.oacIdOar
    WHERE (TempOfferteArticoli.oarIdOff = @IdOff))
GO
