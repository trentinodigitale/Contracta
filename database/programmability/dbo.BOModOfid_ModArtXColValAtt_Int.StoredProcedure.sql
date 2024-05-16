USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOfid_ModArtXColValAtt_Int]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModOfid_ModArtXColValAtt_Int](@IdMdl INT) AS
/*  SELECT ValoriAttributi_Int.* FROM ModelliArticoli
    INNER JOIN ModelliGruppi ON ModelliArticoli.marIdMgr = ModelliGruppi.IdMgr
    INNER JOIN ModelliArticoliXColonne ON ModelliArticoli.IdMar = ModelliArticoliXColonne.macIdMar
    INNER JOIN ModelliColonne ON ModelliArticoliXColonne.macIdMcl = ModelliColonne.IdMcl AND ModelliGruppi.mgrIdMdl = ModelliColonne.mclIdMdl
    INNER JOIN ValoriAttributi_Int ON ModelliArticoliXColonne.macIdVat = ValoriAttributi_Int.IdVat
    WHERE (ModelliGruppi.mgrIdMdl = @IdMdl) */
 SELECT * FROM ValoriAttributi_Int WHERE IdVat IN (
  SELECT macIdVat FROM ModelliArticoliXColonne
   INNER JOIN ModelliArticoli ON ModelliArticoli.Idmar = ModelliArticoliXColonne.macIdMar
   INNER JOIN ModelliGruppi ON ModelliGruppi.IdMgr = ModelliArticoli.marIdMgr
   WHERE (ModelliGruppi.mgrIdMdl = @IdMdl)  UNION
  SELECT mclIdVatDefault FROM ModelliColonne
   WHERE mclIdMdl = @IdMdl
  )
GO
