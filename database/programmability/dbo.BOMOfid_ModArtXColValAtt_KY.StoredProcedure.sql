USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOMOfid_ModArtXColValAtt_KY]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOMOfid_ModArtXColValAtt_KY](@IdMdl INT) AS
/*  SELECT ValoriAttributi_Keys.* FROM ModelliArticoli
    INNER JOIN ModelliGruppi ON ModelliArticoli.marIdMgr = ModelliGruppi.IdMgr
    INNER JOIN ModelliArticoliXColonne ON ModelliArticoli.IdMar = ModelliArticoliXColonne.macIdMar
    INNER JOIN ModelliColonne ON ModelliArticoliXColonne.macIdMcl = ModelliColonne.IdMcl AND ModelliGruppi.mgrIdMdl = ModelliColonne.mclIdMdl
    INNER JOIN ValoriAttributi_Keys ON ModelliArticoliXColonne.macIdVat = ValoriAttributi_Keys.IdVat
    WHERE (ModelliGruppi.mgrIdMdl = @IdMdl) */
 SELECT * FROM ValoriAttributi_Keys WHERE IdVat IN (
  SELECT macIdVat FROM ModelliArticoliXColonne
   INNER JOIN ModelliArticoli ON ModelliArticoli.Idmar = ModelliArticoliXColonne.macIdMar
   INNER JOIN ModelliGruppi ON ModelliGruppi.IdMgr = ModelliArticoli.marIdMgr
   WHERE (ModelliGruppi.mgrIdMdl = @IdMdl)  UNION
  SELECT mclIdVatDefault FROM ModelliColonne
   WHERE mclIdMdl = @IdMdl
  )
GO
