USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModRic_ValAtt]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOModRic_ValAtt](@IdRic INT) AS
/*  SELECT ValoriAttributi.* FROM ValoriAttributi
    INNER JOIN RicercheParametri ON RicercheParametri.rpmIdVat = ValoriAttributi.IdVat
    WHERE (RicercheParametri.rpmIdRic = @IdRic)
    ORDER BY ValoriAttributi.IdVat */
 SELECT * 
 FROM ValoriAttributi 
 WHERE IdVat IN (
  SELECT  rpmIdVat 
  FROM  RicercheParametri
  WHERE  RicercheParametri.rpmIdRic = @IdRic
  )
 ORDER BY ValoriAttributi.IdVat
GO
