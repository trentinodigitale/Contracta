USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOfid_ModArtXCol]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOModOfid_ModArtXCol](@IdMdl INT) AS
/*  SELECT ModelliArticoliXColonne.* FROM ModelliArticoli
    INNER JOIN ModelliGruppi ON ModelliArticoli.marIdMgr = ModelliGruppi.IdMgr
    INNER JOIN ModelliArticoliXColonne ON ModelliArticoli.IdMar = ModelliArticoliXColonne.macIdMar
    INNER JOIN ModelliColonne ON ModelliArticoliXColonne.macIdMcl = ModelliColonne.IdMcl AND ModelliGruppi.mgrIdMdl = ModelliColonne.mclIdMdl
    WHERE (ModelliGruppi.mgrIdMdl = @IdMdl)
 SELECT  *
 FROM ModelliArticoliXColonne
  INNER JOIN ModelliArticoli ON ModelliArticoli.Idmar = ModelliArticoliXColonne.macIdMar
  INNER JOIN ModelliGruppi ON ModelliGruppi.IdMgr = ModelliArticoli.marIdMgr
  WHERE (ModelliGruppi.mgrIdMdl = @IdMdl)*/
 SELECT *
 FROM ModelliArticoliXColonne
 WHERE macIdMcl IN (
  SELECT IdMcl 
  FROM ModelliColonne
  WHERE mclIdMdl = @IdMdl)
GO
