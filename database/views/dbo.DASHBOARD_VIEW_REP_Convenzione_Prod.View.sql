USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REP_Convenzione_Prod]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_REP_Convenzione_Prod]
AS
SELECT RDA_Id
     , RDA_Owner
     , YEAR(RDA_DataCreazione)                                 AS Anno
     , Document_ODC.Id_Convenzione
     , Document_ODC.Id_Convenzione                             AS Convenzione
     , Plant
     , RDP_CodArtProd                                          AS CodiceArticolo
     , RDP_Desc
     , ISNULL(RDP_Importo, 0)                                  AS RDP_Importo
     , ISNULL(RDP_Qt, 0)                                       AS RDP_Qt
     , ISNULL(PercSconto, 0)                                   AS PercSconto
     , (ISNULL(RDP_Importo, 0) * ISNULL(RDP_Qt, 0)) - (ISNULL(RDP_Importo, 0) * ISNULL(RDP_Qt, 0)) * ISNULL(PercSconto, 0) / 100
                                                               AS RDA_Total
  FROM Document_ODC
     , Document_ODC_Product
 WHERE RDA_Id = RDP_RDA_Id
   AND RDA_Deleted = ' '
   AND RDA_Stato <> 'Saved'
UNION
SELECT RDA_Id
     , b.IdPfu                                                 AS RDA_Owner
     , YEAR(RDA_DataCreazione)                                 AS Anno
     , Document_ODC.Id_Convenzione
     , Document_ODC.Id_Convenzione                             AS Convenzione
     , Plant
     , RDP_CodArtProd                                          AS CodiceArticolo
     , RDP_Desc
     , ISNULL(RDP_Importo, 0)                                  AS RDP_Importo
     , ISNULL(RDP_Qt, 0)                                       AS RDP_Qt
     , ISNULL(PercSconto, 0)                                   AS PercSconto
     , (ISNULL(RDP_Importo, 0) * ISNULL(RDP_Qt, 0)) - (ISNULL(RDP_Importo, 0) * ISNULL(RDP_Qt, 0)) * ISNULL(PercSconto, 0) / 100
                                                               AS RDA_Total
  FROM Document_ODC
     , Document_ODC_Product
     , ProfiliUtenteAttrib b
 WHERE RDA_Id = RDP_RDA_Id
   AND RDA_Deleted = ' '
   AND RDA_Stato <> 'Saved'
   AND b.attValue = ODC_PEG
   AND b.dztNome = 'FiltroPeg'


GO
