USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_REP_Odc_Prod_ALL_Org]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_REP_Odc_Prod_ALL_Org]
AS
SELECT Document_ODC.Id_Convenzione                             AS RDA_Id
     , YEAR(RDA_DataCreazione)                                 AS Anno
     , Document_ODC.Id_Convenzione
     , Document_ODC.Id_Convenzione                             AS Convenzione
     , RDP_CodArtProd                                          AS CodiceArticolo
     , RDP_Desc
     , ISNULL(RDP_Importo, 0)                                  AS RDP_Importo
     , SUM(ISNULL(RDP_Qt, 0))                                  AS RDP_Qt
     , ISNULL(PercSconto, 0)                                   AS PercSconto
     , SUM((ISNULL(RDP_Importo, 0) * ISNULL(RDP_Qt, 0)) - (ISNULL(RDP_Importo, 0) * ISNULL(RDP_Qt, 0)) * ISNULL(PercSconto, 0) / 100)
                                                               AS RDA_Total
  FROM Document_ODC
     , Document_ODC_Product
 WHERE RDA_Id = RDP_RDA_Id
   AND RDA_Deleted = ' '
   AND RDA_Stato not in ( 'Saved', 'Canceled')
GROUP BY Document_ODC.Id_Convenzione/*, b.IdPfu*/, YEAR(RDA_DataCreazione), RDP_CodArtProd, RDP_Desc, ISNULL(RDP_Importo, 0), ISNULL(PercSconto, 0)



GO
