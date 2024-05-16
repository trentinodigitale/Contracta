USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOfid_ModArticoli]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOModOfid_ModArticoli](@IdMdl INT) AS
  SELECT ModelliArticoli.* FROM ModelliArticoli
    INNER JOIN ModelliGruppi ON ModelliArticoli.marIdMgr = ModelliGruppi.IdMgr
    WHERE (ModelliGruppi.mgrIdMdl = @IdMdl)
GO
