USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOMOfid_ModArtXColValAtt_Fl]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOMOfid_ModArtXColValAtt_Fl](@IdMdl INT) AS
/*  SELECT ValoriAttributi_Float.* FROM ModelliArticoli
    INNER JOIN ModelliGruppi ON ModelliArticoli.marIdMgr = ModelliGruppi.IdMgr
    INNER JOIN ModelliArticoliXColonne ON ModelliArticoli.IdMar = ModelliArticoliXColonne.macIdMar
    INNER JOIN ModelliColonne ON ModelliArticoliXColonne.macIdMcl = ModelliColonne.IdMcl AND ModelliGruppi.mgrIdMdl = ModelliColonne.mclIdMdl
    INNER JOIN ValoriAttributi_Float ON ModelliArticoliXColonne.macIdVat = ValoriAttributi_Float.IdVat
    WHERE (ModelliGruppi.mgrIdMdl = @IdMdl) */
 SELECT * FROM ValoriAttributi_Float WHERE IdVat IN (
  SELECT macIdVat FROM ModelliArticoliXColonne
   INNER JOIN ModelliArticoli ON ModelliArticoli.Idmar = ModelliArticoliXColonne.macIdMar
   INNER JOIN ModelliGruppi ON ModelliGruppi.IdMgr = ModelliArticoli.marIdMgr
   WHERE (ModelliGruppi.mgrIdMdl = @IdMdl)  UNION
  SELECT mclIdVatDefault FROM ModelliColonne
   WHERE mclIdMdl = @IdMdl
  )
GO
