USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOff_OffArticoliNew]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModOff_OffArticoliNew](@IdOff INT) AS
  SELECT OfferteArticoli.*
FROM OfferteArticoli
    WHERE (OfferteArticoli.oarIdOff = @IdOff)
GO
