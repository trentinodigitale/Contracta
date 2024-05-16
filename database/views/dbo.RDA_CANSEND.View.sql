USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RDA_CANSEND]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[RDA_CANSEND]
AS
SELECT     dbo.Document_RDA.RDA_ID AS ID_DOC, dbo.Document_RDA.RDA_Owner, dbo.Document_RDA.RDA_Name, dbo.Document_RDA.RDA_AZI, 
                      dbo.Document_RDA.RDA_DataScad, dbo.Document_RDA.RDA_Plant_CDC, dbo.Document_RDA.RDA_Valuta, dbo.Document_RDA.RDA_BDG_Periodo, 
                      dbo.Document_RDA_Product.RDP_VDS, NULLIF (dbo.Document_RDA_Product.RDP_Importo, 0) AS RDP_Importo, 
                      NULLIF (dbo.Document_RDA_Product.RDP_Qt, 0) AS RDP_Qt
FROM         dbo.Document_RDA INNER JOIN
                      dbo.Document_RDA_Product ON dbo.Document_RDA.RDA_ID = dbo.Document_RDA_Product.RDP_RDA_ID
WHERE     (dbo.Document_RDA.RDA_Owner IS NULL) OR
                      (dbo.Document_RDA.RDA_Owner = '') OR
                      (dbo.Document_RDA.RDA_Name IS NULL) OR
                      (dbo.Document_RDA.RDA_Name = '') OR
                      (dbo.Document_RDA.RDA_Plant_CDC IS NULL) OR
                      (dbo.Document_RDA.RDA_Plant_CDC = '') OR
                      (dbo.Document_RDA.RDA_Valuta IS NULL) OR
                      (dbo.Document_RDA.RDA_Valuta = '') OR
                      (dbo.Document_RDA.RDA_BDG_Periodo IS NULL) OR
                      (dbo.Document_RDA.RDA_BDG_Periodo = '') OR
                      (dbo.Document_RDA_Product.RDP_VDS IS NULL) OR
                      (dbo.Document_RDA_Product.RDP_VDS = '') OR
                      (dbo.Document_RDA_Product.RDP_Importo = 0) OR
                      (dbo.Document_RDA_Product.RDP_Importo IS NULL) OR
                      (dbo.Document_RDA_Product.RDP_Qt = 0) OR
                      (dbo.Document_RDA_Product.RDP_Qt IS NULL) OR
                      (dbo.Document_RDA.RDA_DataScad IS NULL)


GO
