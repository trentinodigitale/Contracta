USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TempOff_OffArtXCol]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[TempOff_OffArtXCol](@IdOff INT)
with recompile
 AS
 SELECT  TempOfferteArticoliXColonne.* 
  FROM TempOfferteArticoliXColonne
  WHERE (oacIdOar IN (
   SELECT TempOfferteArticoli.IdOar
    FROM TempOfferteArticoli
    WHERE TempOfferteArticoli.oarIdOff = @IdOff))
GO
