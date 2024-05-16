USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModRic_ValAttDTime]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOModRic_ValAttDTime](@IdRic INT) AS
/*  SELECT ValoriAttributi_Datetime.* FROM ValoriAttributi_Datetime 
    INNER JOIN RicercheParametri ON ValoriAttributi_Datetime.IdVat = RicercheParametri.rpmIdVat
    WHERE (RicercheParametri.rpmIdRic = @IdRic)
    ORDER BY ValoriAttributi_Datetime.IdVat */
 SELECT * 
 FROM ValoriAttributi_Datetime 
 WHERE IdVat IN (
  SELECT  rpmIdVat 
  FROM  RicercheParametri
  WHERE  RicercheParametri.rpmIdRic = @IdRic )
 ORDER BY ValoriAttributi_Datetime.IdVat
GO
