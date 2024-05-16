USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TempOff_OffColonne]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[TempOff_OffColonne](@IdOff INT)
with recompile
 AS
  SELECT TempModelliColonne.* FROM TempModelliColonne
    WHERE (TempModelliColonne.mclIdMdl = (SELECT DISTINCT offIdMdl FROM TempOfferte WHERE IdOff = @IdOff))
GO
