USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOProUte_SPfuCsp]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOProUte_SPfuCsp] (@IdAzi INT) AS
  SELECT DfSPfuCsp.* FROM DfSPfuCsp
    INNER JOIN ProfiliUtente ON DfSPfuCsp.IdPfu = ProfiliUtente.IdPfu
    WHERE (ProfiliUtente.pfuIdAzi = @IdAzi)
GO
