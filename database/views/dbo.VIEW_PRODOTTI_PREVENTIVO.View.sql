USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_PRODOTTI_PREVENTIVO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[VIEW_PRODOTTI_PREVENTIVO]
AS
SELECT     dbo.Document_RDA.RDA_ID AS iddoc, dbo.Document_RDA.RDA_ID, dbo.Document_RDA_Product.RDP_idRow AS Row, 
                      SUBSTRING(dbo.Document_RDA.RDA_Plant_CDC, CHARINDEX('#~#', dbo.Document_RDA.RDA_Plant_CDC) + 3, 100) AS CDC, 
                      dbo.Document_RDA_Product.RDP_VDS,  dbo.Document_RDA_Product.RDP_Desc AS DescrAttach, dbo.Document_RDA_Product.RDP_qt AS CARQuantitaDaOrdinare
FROM         dbo.Document_RDA INNER JOIN
                      dbo.Document_RDA_Product ON dbo.Document_RDA.RDA_ID = dbo.Document_RDA_Product.RDP_RDA_ID



GO
