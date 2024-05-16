USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BORicerche_DizionarioAttMSG]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BORicerche_DizionarioAttMSG] (@IdModRic INT, @IdModVis INT) 
AS
SELECT v.IdDzt, v.dztNomeEffettivo, cast(sum(v.dztFArticoli) AS bit) AS dztFArticoli, 
                                    cast(sum(v.dztFMessaggio) AS bit) AS dztFMessaggio, 
                v.dztTabellaSpeciale, v.dztCampoSpeciale, 
                v.dztNome, v.dztIdTid, v.tidTipoDom, v.dztVersoNavig, v.dztIsUnicode
from
(
SELECT 
      IdDzt,
      DizionarioAttributi.dztNome AS dztNomeEffettivo,
      cast (0 AS INT) AS dztFArticoli,
      cast (1 AS INT) AS dztFMessaggio,
      ISNULL(apatTabellaSpeciale,'') AS dztTabellaSpeciale,
      ISNULL(apatCampoSpeciale,'') AS dztCampoSpeciale,
      DescsI.dscTesto AS dztNome,
      dztIdTid,
      tidTipoDom,
        dztVersoNavig,
      apatISUnicode as dztIsUnicode
FROM DizionarioAttributi
inner join DescsI on DizionarioAttributi.dztIdDsc=DescsI.idDsc
inner join tipidati on dztIdTid = IdTid
inner join AppartenenzaAttributi on apatIdDzt = IdDzt
WHERE apatIdApp = 15 AND dztDeleted = 0 AND apatDeleted = 0
union
SELECT 
      IdDzt,
      DizionarioAttributi.dztNome AS dztNomeEffettivo,
      cast (1 AS INT) AS dztFArticoli,
      cast (0 AS INT) AS dztFMessaggio,
      ISNULL(apatTabellaSpeciale,'') AS dztTabellaSpeciale,
      ISNULL(apatCampoSpeciale,'') AS dztCampoSpeciale,
      DescsI.dscTesto AS dztNome,
      dztIdTid,
      tidTipoDom,
        dztVersoNavig,
      apatISUnicode as dztIsUnicode
FROM DizionarioAttributi
inner join DescsI on DizionarioAttributi.dztIdDsc=DescsI.idDsc
inner join tipidati on dztIdTid = IdTid
inner join AppartenenzaAttributi on apatIdDzt = IdDzt
WHERE apatIdApp = 14 AND dztDeleted = 0 AND apatDeleted = 0
) v
--WHERE v.IdDzt in (SELECT mpmaIdDzt FROM MPModelliAttributi WHERE mpmaDeleted = 0 AND mpmaidMpMod in (@IdModRic,@IdModVis))
group by v.IdDzt, v.dztNomeEffettivo, v.dztTabellaSpeciale, v.dztCampoSpeciale, 
                v.dztNome, v.dztIdTid, v.tidTipoDom, v.dztVersoNavig, v.dztIsUnicode
ORDER BY v.IdDzt
GO
