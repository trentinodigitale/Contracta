USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModRic_EleArt]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModRic_EleArt](@IdRic INT) AS
 SELECT * 
  FROM RicercheArticoli
  WHERE (RicercheArticoli.racIdRic = @IdRic)
  ORDER BY RicercheArticoli.racIdArt
GO
