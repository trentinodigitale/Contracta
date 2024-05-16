USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOProUte_Profili]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOProUte_Profili](@IdAzi INT) AS
  SELECT * FROM ProfiliUtente
    WHERE pfuIdAzi = @IdAzi AND pfuDeleted = 0
    ORDER BY IdPfu
GO
