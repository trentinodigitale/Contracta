USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REP_Odc_Prod]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[DASHBOARD_VIEW_REP_Odc_Prod]
AS
SELECT Document_ODC.Id_Convenzione                             AS RDA_Id
     , b.IdPfu                                                 AS RDA_Owner
     , YEAR(RDA_DataCreazione)                                 AS Anno
     , Document_ODC.Id_Convenzione
     , Document_ODC.Id_Convenzione                             AS Convenzione
     , vPeg.DMV_CodExt + ' - ' + vPlant.DMV_DescML             AS PegPlant
     , RDP_CodArtProd                                          AS CodiceArticolo
     , RDP_Desc
     , ISNULL(RDP_Importo, 0)                                  AS RDP_Importo
     , SUM(ISNULL(RDP_Qt, 0))                                  AS RDP_Qt
     , ISNULL(PercSconto, 0)                                   AS PercSconto
     , SUM((ISNULL(RDP_Importo, 0) * ISNULL(RDP_Qt, 0) * ISNULL(CoefCorr, 1)) - (ISNULL(RDP_Importo, 0) * ISNULL(RDP_Qt, 0) * ISNULL(CoefCorr, 1)) * ISNULL(PercSconto, 0) / 100)
                                                               AS RDA_Total
     , ISNULL(CoefCorr, 1) AS CoefCorr
  FROM Document_ODC
     , Document_ODC_Product
     , ProfiliUtenteAttrib b
     , (SELECT DISTINCT 'peg_prog' AS DMV_DM_ID
             , '35152001#\0000\0000\00' + CodProgramma    AS DMV_Cod 
             , '35152001#\0000\0000\00' + CodProgramma    AS DMV_Father 
             , 1                                          AS DMV_Level 
             , SUBSTRING(REPLACE(Programma, 'à', 'a'), 5, 500)               
                                                          AS DMV_DescML 
             , 'folder.gif'                               AS DMV_Image 
             , 0                                          AS DMV_Sort 
             , CodProgramma                               AS DMV_CodExt   
          FROM peg) as vPeg
     , (SELECT DISTINCT 'peg_prog' AS DMV_DM_ID
             , '35152001#\0000\0000\00' + CodProgramma    AS DMV_Cod 
             , '35152001#\0000\0000\00' + CodProgramma    AS DMV_Father 
             , 1                                          AS DMV_Level 
             , SUBSTRING(REPLACE(Programma, 'à', 'a'), 5, 500)               
                                                          AS DMV_DescML 
             , 'folder.gif'                               AS DMV_Image 
             , 0                                          AS DMV_Sort 
             , CodProgramma                               AS DMV_CodExt   
          FROM peg) as vPlant
 WHERE RDA_Id = RDP_RDA_Id
   AND vPlant.DMV_Cod = Document_ODC.Plant
   AND vPeg.DMV_CodExt = RIGHT(Document_ODC.ODC_PEG, 2)
   AND RDA_Deleted = ' '
   AND RDA_Stato not in ( 'Saved', 'Canceled')
   AND b.attValue = ODC_PEG
   AND b.dztNome = 'FiltroPeg'
GROUP BY Document_ODC.Id_Convenzione, b.IdPfu, YEAR(RDA_DataCreazione), Document_ODC.Id_Convenzione, vPeg.DMV_CodExt + ' - ' + vPlant.DMV_DescML, RDP_CodArtProd, RDP_Desc, ISNULL(RDP_Importo, 0), ISNULL(PercSconto, 0), ISNULL(CoefCorr, 1)



GO
