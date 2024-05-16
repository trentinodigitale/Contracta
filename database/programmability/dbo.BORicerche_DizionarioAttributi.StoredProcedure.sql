USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BORicerche_DizionarioAttributi]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BORicerche_DizionarioAttributi]  AS 
SELECT 
      IdDzt,
      DizionarioAttributi.dztNome AS dztNomeEffettivo,
      dztFAziende,
      dztFArticoli,
      ISNULL(dztTabellaSpeciale,'') AS dztTabellaSpeciale,
      ISNULL(dztCampoSpeciale,'') AS dztCampoSpeciale,
      DescsI.dscTesto AS dztNome,
      dztIdTid,
      tidTipoDom,
     dztVersoNavig,
     dztIsUnicode
FROM DizionarioAttributi
inner join DescsI on DizionarioAttributi.dztIdDsc=DescsI.idDsc
inner join tipidati on dztIdTid = IdTid
WHERE (dztFAziende = 1 or dztFArticoli = 1) 
and  IdDzt not in( SELECT IdDzt FROM DizionarioAttributi
inner join AppartenenzaAttributi on DizionarioAttributi.Iddzt=AppartenenzaAttributi.apatIdDzt WHERE apatIdApp=16 )
UNION
SELECT 
      IdDzt,
      DizionarioAttributi.dztNome AS dztNomeEffettivo,
      dztFAziende,
      dztFArticoli,
      ISNULL(apatTabellaSpeciale,'')  AS dztTabellaSpeciale,
      ISNULL(apatCampoSpeciale,'') AS dztCampoSpeciale,
      DescsI.dscTesto AS dztNome,
      dztIdTid,
      tidTipoDom,
        dztVersoNavig,
     apatIsUnicode as dztIsUnicode
FROM DizionarioAttributi
inner join AppartenenzaAttributi on DizionarioAttributi.Iddzt=AppartenenzaAttributi.apatIdDzt
inner join DescsI on DizionarioAttributi.dztIdDsc=DescsI.idDsc
inner join tipidati on dztIdTid = IdTid
WHERE (dztFAziende = 1 or dztFArticoli = 1) AND apatIdApp=16
ORDER BY IdDzt
GO
