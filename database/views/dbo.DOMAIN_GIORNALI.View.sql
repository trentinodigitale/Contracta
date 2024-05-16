USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOMAIN_GIORNALI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DOMAIN_GIORNALI]
AS
SELECT DISTINCT 
                      'GIORNALI' AS DMV_DM_ID, DMV_Cod, DMV_Cod AS DMV_Father, 1 AS DMV_Level, DMV_DescML, 'folder.gif' AS DMV_Image, 0 AS DMV_Sort, 
                      DMV_CodExt
FROM         dbo.LIB_DomainValues
WHERE     (DMV_DM_ID = 'Diffusione')
UNION
SELECT     TOP 100 PERCENT 'GIORNALI' AS DMV_DM_ID, CAST(Id AS varchar) AS DMV_Cod, Diffusione + RIGHT('00000' + CAST(Id AS varchar), 6) 
                      AS DMV_Father, 2 AS DMV_Level, Quotidiano AS DMV_DescML, 'node.gif' AS DMV_Image, 0 AS DMV_Sort, CAST(Id AS varchar) AS DMV_CodExt
FROM         dbo.Document_Quotidiani
ORDER BY DMV_Father


GO
