USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModRic_ValAttInt]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOModRic_ValAttInt](@IdRic INT) AS
/*  SELECT ValoriAttributi_Int.* FROM ValoriAttributi_Int 
    INNER JOIN RicercheParametri ON ValoriAttributi_Int.IdVat = RicercheParametri.rpmIdVat
    WHERE (RicercheParametri.rpmIdRic = @IdRic)
    ORDER BY ValoriAttributi_Int.IdVat */
 SELECT * 
 FROM ValoriAttributi_Int 
 WHERE IdVat IN (
  SELECT  rpmIdVat 
  FROM  RicercheParametri
  WHERE  RicercheParametri.rpmIdRic = @IdRic )
 ORDER BY ValoriAttributi_Int.IdVat
GO
