USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOfid_ModArtXColValAtt]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModOfid_ModArtXColValAtt](@IdMdl INT) AS
/*  SELECT ValoriAttributi.* FROM ModelliArticoli
    INNER JOIN ModelliGruppi ON ModelliArticoli.marIdMgr = ModelliGruppi.IdMgr
    INNER JOIN ModelliArticoliXColonne ON ModelliArticoli.IdMar = ModelliArticoliXColonne.macIdMar
    INNER JOIN ModelliColonne ON ModelliArticoliXColonne.macIdMcl = ModelliColonne.IdMcl AND ModelliGruppi.mgrIdMdl = ModelliColonne.mclIdMdl
    INNER JOIN ValoriAttributi ON ModelliArticoliXColonne.macIdVat = ValoriAttributi.IdVat
    WHERE (ModelliGruppi.mgrIdMdl = @IdMdl) */
/*  SELECT ValoriAttributi.* FROM ValoriAttributi
    INNER JOIN ModelliArticoliXColonne ON ModelliArticoliXColonne.macIdvat = ValoriAttributi.IdVat
    INNER JOIN ModelliArticoli ON ModelliArticoli.Idmar = ModelliArticoliXColonne.macIdMar
    INNER JOIN ModelliGruppi ON ModelliGruppi.IdMgr = ModelliArticoli.marIdMgr
    WHERE (ModelliGruppi.mgrIdMdl = @IdMdl) */
 SELECT * FROM ValoriAttributi WHERE IdVat IN (
  SELECT macIdVat FROM ModelliArticoliXColonne
   INNER JOIN ModelliArticoli ON ModelliArticoli.Idmar = ModelliArticoliXColonne.macIdMar
   INNER JOIN ModelliGruppi ON ModelliGruppi.IdMgr = ModelliArticoli.marIdMgr
   WHERE (ModelliGruppi.mgrIdMdl = @IdMdl)  UNION
  SELECT mclIdVatDefault FROM ModelliColonne
   WHERE mclIdMdl = @IdMdl
  )
GO
