USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOProUte_BPfuCsp]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOProUte_BPfuCsp] (@IdAzi INT) AS
  SELECT DfBPfuCsp.* FROM DfBPfuCsp
    INNER JOIN ProfiliUtente ON DfBPfuCsp.IdPfu = ProfiliUtente.IdPfu
    WHERE (ProfiliUtente.pfuIdAzi = @IdAzi)
GO
