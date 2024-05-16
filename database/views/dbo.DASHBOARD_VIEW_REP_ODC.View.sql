USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REP_ODC]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_REP_ODC]
AS
SELECT Id_Convenzione                                                   AS RDA_Id
     , RDA_Owner
     , Id_Convenzione    
     , vPeg.DMV_CodExt + ' - ' + vPlant.DMV_DescML                      AS PegPlant
     , vPeg.DMV_CodExt + ' - ' + vPlant.DMV_DescML                      AS PegPlant_Sort
     , SUM(RDA_Total)                                                   AS RDA_Total
     , SUM(TotalIva)                                                    AS TotalIva
     , Id_Convenzione                                                   AS Convenzione
     , YEAR (RDA_DataCreazione)                                         AS Anno
     , -YEAR (RDA_DataCreazione)                                        AS Anno_Sort
     , Doc_Name
     , Protocol
     , CAST(DescrizioneEstesa AS VARCHAR(8000))                         AS DescrizioneEstesa
  FROM Document_ODC
     , Document_Convenzione
     , (SELECT DISTINCT 'peg_prog' AS DMV_DM_ID
             , '35152001#\0000\0000\00' + CodProgramma    AS DMV_Cod 
             , '35152001#\0000\0000\00' + CodProgramma    AS DMV_Father 
             , 1                                          AS DMV_Level 
             , SUBSTRING(REPLACE(REPLACE(Programma, 'à', 'a'), '''', ' '), 5, 500)               
                                                          AS DMV_DescML 
             , 'folder.gif'                               AS DMV_Image 
             , 0                                          AS DMV_Sort 
             , CodProgramma                               AS DMV_CodExt   
          FROM peg) as vPeg
     , (SELECT DISTINCT 'peg_prog' AS DMV_DM_ID
             , '35152001#\0000\0000\00' + CodProgramma    AS DMV_Cod 
             , '35152001#\0000\0000\00' + CodProgramma    AS DMV_Father 
             , 1                                          AS DMV_Level 
             , SUBSTRING(REPLACE(REPLACE(Programma, 'à', 'a'), '''', ' '), 5, 500)               
                                                          AS DMV_DescML 
             , 'folder.gif'                               AS DMV_Image 
             , 0                                          AS DMV_Sort 
             , CodProgramma                               AS DMV_CodExt   
          FROM peg) as vPlant
 WHERE Document_Convenzione.Id = Document_ODC.Id_Convenzione
   AND vPlant.DMV_Cod = Document_ODC.Plant
   AND vPeg.DMV_CodExt = RIGHT(Document_ODC.ODC_PEG, 2)
   AND RDA_Deleted = ' '
   AND RDA_Stato <> 'Saved'
GROUP BY Id_Convenzione, RDA_Owner, vPeg.DMV_CodExt + ' - ' + vPlant.DMV_DescML, YEAR (RDA_DataCreazione),-YEAR (RDA_DataCreazione), Doc_Name, Protocol, CAST(DescrizioneEstesa AS VARCHAR(8000)), Document_ODC.ODC_Peg
UNION 
SELECT Id_Convenzione                                                   AS RDA_Id
     , b.IdPfu                                                          AS RDA_Owner
     , Id_Convenzione                                
     , vPeg.DMV_CodExt + ' - ' + vPlant.DMV_DescML                      AS PegPlant
     , vPeg.DMV_CodExt + ' - ' + vPlant.DMV_DescML                      AS PegPlant_Sort
     , SUM(RDA_Total)                                                   AS RDA_Total
     , SUM(TotalIva)                                                    AS TotalIva
     , Id_Convenzione                                                   AS Convenzione
     , YEAR (RDA_DataCreazione)                                         AS Anno
     , -YEAR (RDA_DataCreazione)                                        AS Anno_Sort
     , Doc_Name
     , Protocol
     , CAST(DescrizioneEstesa AS VARCHAR(8000))                         AS DescrizioneEstesa
  FROM Document_ODC
     , Document_Convenzione
     , ProfiliUtente a
     , ProfiliUtenteAttrib b
     , (SELECT DISTINCT 'peg_prog' AS DMV_DM_ID
             , '35152001#\0000\0000\00' + CodProgramma    AS DMV_Cod 
             , '35152001#\0000\0000\00' + CodProgramma    AS DMV_Father 
             , 1                                          AS DMV_Level 
             , SUBSTRING(REPLACE(REPLACE(Programma, 'à', 'a'), '''', ' '), 5, 500)               
                                                          AS DMV_DescML 
             , 'folder.gif'                               AS DMV_Image 
             , 0                                          AS DMV_Sort 
             , CodProgramma                               AS DMV_CodExt   
          FROM peg) as vPeg
     , (SELECT DISTINCT 'peg_prog' AS DMV_DM_ID
             , '35152001#\0000\0000\00' + CodProgramma    AS DMV_Cod 
             , '35152001#\0000\0000\00' + CodProgramma    AS DMV_Father 
             , 1                                          AS DMV_Level 
             , SUBSTRING(REPLACE(REPLACE(Programma, 'à', 'a'), '''', ' '), 5, 500)               
                                                          AS DMV_DescML 
             , 'folder.gif'                               AS DMV_Image 
             , 0                                          AS DMV_Sort 
             , CodProgramma                               AS DMV_CodExt   
          FROM peg) as vPlant
 WHERE Document_Convenzione.Id = Document_ODC.Id_Convenzione
   AND vPlant.DMV_Cod = Document_ODC.Plant
   AND vPeg.DMV_CodExt = RIGHT(Document_ODC.ODC_PEG, 2)
   AND RDA_Owner = CAST(a.IdPfu AS VARCHAR)
   AND b.attValue = ODC_PEG
   AND b.dztNome = 'FiltroPeg'
   AND RDA_Deleted = ' '
   AND RDA_Stato <> 'Saved'
GROUP BY Id_Convenzione, b.IdPfu, vPeg.DMV_CodExt + ' - ' + vPlant.DMV_DescML, YEAR (RDA_DataCreazione) , -YEAR (RDA_DataCreazione), Doc_Name, Protocol, CAST(DescrizioneEstesa AS VARCHAR(8000)), Document_ODC.ODC_Peg





GO
