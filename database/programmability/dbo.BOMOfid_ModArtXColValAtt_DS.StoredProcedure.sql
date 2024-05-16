USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOMOfid_ModArtXColValAtt_DS]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOMOfid_ModArtXColValAtt_DS](@IdMdl INT) AS
 /* SELECT ValoriAttributi_Descrizioni.*, DescsI.dscTesto AS dscTestoI, DescsUK.dscTesto AS dscTestoUK FROM ModelliArticoli
    INNER JOIN ModelliGruppi ON ModelliArticoli.marIdMgr = ModelliGruppi.IdMgr
    INNER JOIN ModelliArticoliXColonne ON ModelliArticoli.IdMar = ModelliArticoliXColonne.macIdMar
    INNER JOIN ModelliColonne ON ModelliArticoliXColonne.macIdMcl = ModelliColonne.IdMcl AND ModelliGruppi.mgrIdMdl = ModelliColonne.mclIdMdl
    INNER JOIN ValoriAttributi_Descrizioni ON ModelliArticoliXColonne.macIdVat = ValoriAttributi_Descrizioni.IdVat
    INNER JOIN DescsI ON ValoriAttributi_Descrizioni.vatIdDsc = DescsI.IdDsc
    INNER JOIN DescsUK ON DescsI.IdDsc = DescsUK.IdDsc
    WHERE (ModelliGruppi.mgrIdMdl = @IdMdl) */
 SELECT ValoriAttributi_Descrizioni.*, DescsI.dscTesto AS dscTestoI, DescsUK.dscTesto AS dscTestoUK, DescsE.dscTesto AS dscTestoE, DescsFRA.dscTesto AS dscTestoFRA,DescsLng1.dscTesto AS dscTestoLng1,DescsLng2.dscTesto AS dscTestoLng2,DescsLng3.dscTesto AS dscTestoLng3,DescsLng4.dscTesto AS dscTestoLng4
  FROM ValoriAttributi_Descrizioni 
      INNER JOIN DescsI ON ValoriAttributi_Descrizioni.vatIdDsc = DescsI.IdDsc
      INNER JOIN DescsUK ON DescsI.IdDsc = DescsUK.IdDsc
      INNER JOIN DescsE ON DescsI.IdDsc = DescsE.IdDsc
      INNER JOIN DescsFRA ON DescsI.IdDsc = DescsFRA.IdDsc
      INNER JOIN DescsLng1 ON DescsI.IdDsc = DescsLng1.IdDsc
      INNER JOIN DescsLng2 ON DescsI.IdDsc = DescsLng2.IdDsc
      INNER JOIN DescsLng3 ON DescsI.IdDsc = DescsLng3.IdDsc
      INNER JOIN DescsLng4 ON DescsI.IdDsc = DescsLng4.IdDsc
  WHERE IdVat IN (
  SELECT macIdVat FROM ModelliArticoliXColonne
   INNER JOIN ModelliArticoli ON ModelliArticoli.Idmar = ModelliArticoliXColonne.macIdMar
   INNER JOIN ModelliGruppi ON ModelliGruppi.IdMgr = ModelliArticoli.marIdMgr
   WHERE (ModelliGruppi.mgrIdMdl = @IdMdl)  UNION
  SELECT mclIdVatDefault FROM ModelliColonne
   WHERE mclIdMdl = @IdMdl
  )
GO
