USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REP_Convenzioni_Prod]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_REP_Convenzioni_Prod]
AS
SELECT RDA_Id
     , RDA_Owner
     , Anno
     , Id_Convenzione
     , Convenzione
     , CodiceArticolo
     , RDP_Desc
     , RDP_Importo
     , SUM(RDP_Qt)                                             AS RDP_Qt
     , PercSconto
     , SUM(RDA_Total)                                          AS RDA_Total
     , Merceologia2
  FROM (SELECT Document_ODC.Id_Convenzione                             AS RDA_Id
             , b.IdPfu                                                 AS RDA_Owner
             , YEAR(RDA_DataCreazione)                                 AS Anno
             , Document_ODC.Id_Convenzione
             , Document_ODC.Id_Convenzione                             AS Convenzione
             , Document_Convenzione_Product.Codice                     AS CodiceArticolo
             , CASE WHEN ISNULL(RDP_Desc, '') = '' THEN Descrizione                                             
                    ELSE RDP_Desc 
               END                                                     AS RDP_Desc
             , CASE WHEN ISNULL(PrezzoUnitario, 0) = 0 THEN ISNULL(RDP_Importo, 0)                               
                    ELSE ISNULL(PrezzoUnitario, 0)
               END                                                     AS RDP_Importo
             , ISNULL(RDP_Qt, 0)                                       AS RDP_Qt
             , ISNULL(Document_Convenzione_Product.PercSconto, 0)      AS PercSconto
             , (ISNULL(RDP_Importo, 0) * ISNULL(RDP_Qt, 0) * ISNULL(Document_ODC_Product.CoefCorr, 1)) - (ISNULL(RDP_Importo, 0) * ISNULL(RDP_Qt, 0) * ISNULL(Document_ODC_Product.CoefCorr, 1)) * ISNULL(Document_Convenzione_Product.PercSconto, 0) / 100
                                                                       AS RDA_Total
             , v.DMV_DescML                                            AS Merceologia2
             , Document_ODC_Product.CoefCorr
          FROM Document_Convenzione_Product
         LEFT OUTER JOIN 
               Document_ODC_Product ON Document_Convenzione_Product.Codice = Document_ODC_Product.RDP_CodArtProd
         LEFT OUTER JOIN       
          Document_ODC ON RDA_Id = RDP_RDA_Id AND RDA_Deleted = ' ' AND RDA_Stato <> 'Saved' 
         LEFT OUTER JOIN  Document_Convenzione ON Document_Convenzione.Id = Document_Convenzione_Product.IdHeader  
                            AND  Document_ODC.Id_Convenzione = Document_Convenzione.Id
         INNER JOIN
               (SELECT dgCodiceInterno         AS DMV_Cod 
                     , dscTesto                AS DMV_DescML 
                  FROM DominiGerarchici
                     , DizionarioAttributi
                     , DescsI 
                 WHERE dztNome = 'ClasseIscriz'    
                   AND dztIdTid = dgTipoGerarchia     
                   AND dztDeleted = 0     
                   AND IdDsc = dgIdDsc
                   AND dgDeleted = 0) v ON Document_Convenzione.Merceologia = v.DMV_Cod
           INNER JOIN  ProfiliUtenteAttrib b ON b.attValue = ODC_PEG AND b.dztNome = 'FiltroPeg'
         --WHERE --RDA_Id *= RDP_RDA_Id
           --AND 
          -- Document_ODC.Id_Convenzione = Document_Convenzione.Id
           --AND Document_Convenzione.Id = Document_Convenzione_Product.IdHeader
           --AND Document_Convenzione_Product.Codice *= Document_ODC_Product.RDP_CodArtProd
           --AND RDA_Deleted = ' '
           --AND RDA_Stato <> 'Saved'
           --AND b.attValue = ODC_PEG
           --AND b.dztNome = 'FiltroPeg'
           --AND Document_Convenzione.Merceologia = v.DMV_Cod
           ) v2
GROUP BY v2.RDA_Id, v2.Id_Convenzione, v2.Convenzione, v2.RDA_Owner, v2.Anno, v2.CodiceArticolo, v2.RDP_Desc, v2.RDP_Importo, v2.Merceologia2, v2.PercSconto


GO
