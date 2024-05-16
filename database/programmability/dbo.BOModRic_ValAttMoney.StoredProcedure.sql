USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModRic_ValAttMoney]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOModRic_ValAttMoney](@IdRic INT) AS
/*  SELECT ValoriAttributi_Money.* FROM ValoriAttributi_Money 
    INNER JOIN RicercheParametri ON ValoriAttributi_Money.IdVat = RicercheParametri.rpmIdVat
    WHERE (RicercheParametri.rpmIdRic = @IdRic)
    ORDER BY ValoriAttributi_Money.IdVat */
 SELECT * 
 FROM ValoriAttributi_Money
 WHERE IdVat IN (
  SELECT  rpmIdVat 
  FROM  RicercheParametri
  WHERE  RicercheParametri.rpmIdRic = @IdRic )
 ORDER BY ValoriAttributi_Money.IdVat
GO
