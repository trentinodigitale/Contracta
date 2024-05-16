USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModRic_ValAttNChar]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOModRic_ValAttNChar](@IdRic INT) AS
/*  SELECT ValoriAttributi_NVarChar.* FROM ValoriAttributi_NVarChar 
    INNER JOIN RicercheParametri ON ValoriAttributi_NVarChar.IdVat = RicercheParametri.rpmIdVat
    WHERE (RicercheParametri.rpmIdRic = @IdRic)
    ORDER BY ValoriAttributi_NVarChar.IdVat */
 SELECT * 
 FROM ValoriAttributi_Nvarchar
 WHERE IdVat IN (
  SELECT  rpmIdVat 
  FROM  RicercheParametri
  WHERE  RicercheParametri.rpmIdRic = @IdRic )
 ORDER BY ValoriAttributi_Nvarchar.IdVat
GO
