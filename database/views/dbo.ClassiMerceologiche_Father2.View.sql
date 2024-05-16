USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ClassiMerceologiche_Father2]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  view [dbo].[ClassiMerceologiche_Father2] as 


SELECT     v.DMV_Cod, v.DMV_Father, v.DMV_Level, v.DMV_DescML, CASE CHARINDEX('.', v.DMV_CodExt) 
                      WHEN 0 THEN v.DMV_CodExt ELSE RIGHT('00' + LEFT(v.DMV_CodExt, CHARINDEX('.', v.DMV_CodExt) - 1), 2) + SUBSTRING(v.DMV_CodExt, 
                      CHARINDEX('.', v.DMV_CodExt), 10) END AS DMV_CodExt, v_padre2.DMV_Cod AS DMV_Cod_Level2

FROM         (SELECT     dbo.DominiGerarchici.dgCodiceInterno AS DMV_Cod, '000.' + dbo.DominiGerarchici.dgPath AS DMV_Father, 
                                              dbo.DominiGerarchici.dgLivello AS DMV_Level, dbo.DescsI.dscTesto AS DMV_DescML, CASE CHARINDEX('-', dscTesto) 
                                              WHEN 0 THEN '0' ELSE LEFT(dscTesto, CHARINDEX('-', dscTesto) - 1) END AS DMV_CodExt
                       FROM          dbo.DominiGerarchici INNER JOIN
                                              dbo.DizionarioAttributi ON dbo.DominiGerarchici.dgTipoGerarchia = dbo.DizionarioAttributi.dztIdTid INNER JOIN
                                              dbo.DescsI ON dbo.DominiGerarchici.dgIdDsc = dbo.DescsI.IdDsc
                       WHERE      (dbo.DizionarioAttributi.dztNome = 'ClasseIscriz') AND (dbo.DizionarioAttributi.dztDeleted = 0) AND (dbo.DominiGerarchici.dgDeleted = 0)) 
                      AS v INNER JOIN
        dbo.ClassiMerceologiche_Level2 AS v_padre2 ON substring(v.DMV_Father,1,12) = v_padre2.DMV_Father
WHERE     (v.DMV_Level <> 0)
GO
