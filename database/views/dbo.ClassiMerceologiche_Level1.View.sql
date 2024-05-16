USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ClassiMerceologiche_Level1]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  view [dbo].[ClassiMerceologiche_Level1] as 


SELECT v.DMV_Cod 
     , v.DMV_Father
     , v.DMV_Level
     , v.DMV_DescML
  FROM (SELECT dgCodiceInterno         AS DMV_Cod 
             , '000.' + dgPath         AS DMV_Father 
             , dgLivello               AS DMV_Level 
             , dscTesto                AS DMV_DescML 
             , CASE CHARINDEX('-', dscTesto)
                    WHEN 0 THEN '0'
                    ELSE LEFT(dscTesto, CHARINDEX('-', dscTesto) -  1)
                END                    AS DMV_CodExt 
          FROM DominiGerarchici
             , DizionarioAttributi
             , DescsI 
         WHERE dztNome = 'ClasseIscriz'    
           AND dztIdTid = dgTipoGerarchia     
           AND dztDeleted = 0     
           AND IdDsc = dgIdDsc
           AND dgDeleted = 0 
		) v

where DMV_Level = 1

GO
