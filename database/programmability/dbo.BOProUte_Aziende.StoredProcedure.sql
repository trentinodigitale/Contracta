USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOProUte_Aziende]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOProUte_Aziende](@IdAzi INT) AS
  SELECT * FROM Aziende
    WHERE IdAzi = @IdAzi
GO
