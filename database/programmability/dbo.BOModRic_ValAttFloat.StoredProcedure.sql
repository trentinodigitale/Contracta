USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModRic_ValAttFloat]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOModRic_ValAttFloat](@IdRic INT) AS
/*  SELECT ValoriAttributi_Float.* FROM ValoriAttributi_Float 
    INNER JOIN RicercheParametri ON ValoriAttributi_Float.IdVat = RicercheParametri.rpmIdVat
    WHERE (RicercheParametri.rpmIdRic = @IdRic)
    ORDER BY ValoriAttributi_Float.IdVat */
 SELECT * 
 FROM ValoriAttributi_Float 
 WHERE IdVat IN (
  SELECT  rpmIdVat 
  FROM  RicercheParametri
  WHERE  RicercheParametri.rpmIdRic = @IdRic )
 ORDER BY ValoriAttributi_Float.IdVat
GO
