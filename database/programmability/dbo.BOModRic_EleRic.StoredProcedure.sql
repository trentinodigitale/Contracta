USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModRic_EleRic]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModRic_EleRic](@IdPfu INT) AS
  SELECT * FROM Ricerche
    WHERE ricIdPfu = @IdPfu
    ORDER BY IdRic
GO
