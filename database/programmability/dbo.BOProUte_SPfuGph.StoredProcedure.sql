USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOProUte_SPfuGph]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOProUte_SPfuGph] (@IdAzi INT) AS
  SELECT DfSPfuGph.* FROM DfSPfuGph
    INNER JOIN ProfiliUtente ON DfSPfuGph.IdPfu = ProfiliUtente.IdPfu
    WHERE (ProfiliUtente.pfuIdAzi = @IdAzi)
GO
