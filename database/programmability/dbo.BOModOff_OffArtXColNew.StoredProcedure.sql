USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOff_OffArtXColNew]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModOff_OffArtXColNew](@IdOff INT) AS
 SELECT  OfferteArticoliXColonne.*
  FROM OfferteArticoliXColonne
  WHERE (oacIdOar IN (
   SELECT OfferteArticoli.IdOar
    FROM OfferteArticoli
    WHERE OfferteArticoli.oarIdOff = @IdOff))
GO
