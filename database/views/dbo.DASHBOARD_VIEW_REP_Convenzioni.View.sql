USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REP_Convenzioni]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_REP_Convenzioni]
AS

SELECT Id_Convenzione                                                   AS RDA_Id
     , b.IdPfu                                                          AS RDA_Owner
     , Id_Convenzione                                
     , SUM(RDA_Total)                                                   AS RDA_Total
     , SUM(TotalIva)                                                    AS TotalIva
     , Id_Convenzione                                                   AS Convenzione
     , YEAR (RDA_DataCreazione)                                         AS Anno
     , -YEAR (RDA_DataCreazione)                                        AS Anno_Sort
     , Doc_Name
     , Protocol
     , CAST(DescrizioneEstesa AS VARCHAR(8000))                         AS DescrizioneEstesa
     , v.DMV_DescML                                                     AS Merceologia2                                                      
     , v.DMV_DescML                                                     AS Merceologia2_Sort                                                      
  FROM Document_ODC
     , Document_Convenzione
     , ProfiliUtente a
     , ProfiliUtenteAttrib b
     , (SELECT dgCodiceInterno         AS DMV_Cod 
             , dscTesto                AS DMV_DescML 
          FROM DominiGerarchici
             , DizionarioAttributi
             , DescsI 
         WHERE dztNome = 'ClasseIscriz'    
           AND dztIdTid = dgTipoGerarchia     
           AND dztDeleted = 0     
           AND IdDsc = dgIdDsc
           AND dgDeleted = 0) v
 WHERE Document_Convenzione.Id = Document_ODC.Id_Convenzione
   AND RDA_Owner = CAST(a.IdPfu AS VARCHAR)
   AND b.attValue = ODC_PEG
   AND b.dztNome = 'FiltroPeg'
   AND RDA_Deleted = ' '
   AND RDA_Stato <> 'Saved'
   AND Merceologia = v.DMV_Cod
GROUP BY Id_Convenzione, b.IdPfu, YEAR (RDA_DataCreazione), -YEAR (RDA_DataCreazione), Doc_Name, Protocol, CAST(DescrizioneEstesa AS VARCHAR(8000)), v.DMV_DescML 


GO
