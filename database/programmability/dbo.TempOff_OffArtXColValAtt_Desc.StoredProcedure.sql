USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TempOff_OffArtXColValAtt_Desc]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[TempOff_OffArtXColValAtt_Desc](@IdOff INT)
with recompile
 AS
 SELECT TempValoriAttributi_Descr.*, DescsI.dscTesto AS dscTestoI, DescsUK.dscTesto AS dscTestoUK, DescsE.dscTesto AS dscTestoE, DescsFRA.dscTesto AS dscTestoFRA, DescsLng1.dscTesto AS dscTestoLng1, DescsLng2.dscTesto AS dscTestoLng2, DescsLng3.dscTesto AS dscTestoLng3, DescsLng4.dscTesto AS dscTestoLng4
  FROM TempValoriAttributi_Descr 
   INNER JOIN DescsI ON TempValoriAttributi_Descr.vatIdDsc = DescsI.IdDsc
   INNER JOIN DescsUK ON DescsI.IdDsc = DescsUK.IdDsc
   INNER JOIN DescsE ON DescsI.IdDsc = DescsE.IdDsc
   INNER JOIN DescsFRA ON DescsI.IdDsc = DescsFRA.IdDsc
   INNER JOIN DescsLng1 ON DescsI.IdDsc = DescsLng1.IdDsc
   INNER JOIN DescsLng2 ON DescsI.IdDsc = DescsLng2.IdDsc
   INNER JOIN DescsLng3 ON DescsI.IdDsc = DescsLng3.IdDsc
   INNER JOIN DescsLng4 ON DescsI.IdDsc = DescsLng4.IdDsc
  WHERE IdVat IN (
   SELECT  TempOfferteArticoliXColonne.oacIdVat
    FROM TempOfferteArticoliXColonne
    INNER JOIN TempOfferteArticoli ON TempOfferteArticoli.IdOar = TempOfferteArticoliXColonne.oacIdOar
    WHERE (TempOfferteArticoli.oarIdOff = @IdOff))
GO
