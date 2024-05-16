USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ClassiMerceologiche]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[ClassiMerceologiche] as 


SELECT v.DMV_Cod 
     , v.DMV_Father
     , v.DMV_Level
     , v.DMV_DescML
     , CASE CHARINDEX('.', v.DMV_CodExt)
            WHEN 0 THEN v.DMV_CodExt
            ELSE RIGHT('00' + LEFT(v.DMV_CodExt, CHARINDEX('.', v.DMV_CodExt) - 1), 2) + SUBSTRING(v.DMV_CodExt, CHARINDEX('.', v.DMV_CodExt), 10)
       END AS DMV_CodExt
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

where DMV_Level <> 0


GO
