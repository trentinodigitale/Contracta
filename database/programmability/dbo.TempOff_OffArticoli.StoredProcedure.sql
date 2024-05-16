USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TempOff_OffArticoli]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[TempOff_OffArticoli](@IdOff INT)
with recompile
 AS
  SELECT TempOfferteArticoli.* FROM TempOfferteArticoli
    WHERE (TempOfferteArticoli.oarIdOff = @IdOff)
GO
