USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOMOff_OArtXColValAtt_Fl]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOMOff_OArtXColValAtt_Fl](@IdOff INT) AS
 SELECT  *
  FROM ValoriAttributi_Float
  WHERE IdVat IN (
   SELECT  OfferteArticoliXColonne.oacIdVat
    FROM OfferteArticoliXColonne
    INNER JOIN OfferteArticoli ON OfferteArticoli.IdOar = OfferteArticoliXColonne.oacIdOar
    WHERE (OfferteArticoli.oarIdOff = @IdOff))
GO
