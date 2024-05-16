USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModRic_ValAttKeys]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOModRic_ValAttKeys](@IdRic INT) AS
/*  SELECT ValoriAttributi_Keys.* FROM ValoriAttributi_Keys
    INNER JOIN RicercheParametri ON ValoriAttributi_Keys.IdVat = RicercheParametri.rpmIdVat
    WHERE (RicercheParametri.rpmIdRic = @IdRic)
    ORDER BY ValoriAttributi_Keys.IdVat */
 SELECT * 
 FROM ValoriAttributi_Keys 
 WHERE IdVat IN (
  SELECT  rpmIdVat 
  FROM  RicercheParametri
  WHERE  RicercheParametri.rpmIdRic = @IdRic )
 ORDER BY ValoriAttributi_Keys.IdVat
GO
