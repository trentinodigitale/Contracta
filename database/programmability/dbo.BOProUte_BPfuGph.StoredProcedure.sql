USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOProUte_BPfuGph]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOProUte_BPfuGph] (@IdAzi INT) AS
  SELECT DfBPfuGph.* FROM DfBPfuGph
    INNER JOIN ProfiliUtente ON DfBPfuGph.IdPfu = ProfiliUtente.IdPfu
    WHERE (ProfiliUtente.pfuIdAzi = @IdAzi)
GO
