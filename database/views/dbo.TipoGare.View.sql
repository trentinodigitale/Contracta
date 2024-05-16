USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TipoGare]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[TipoGare]
AS
SELECT     CASE dcmIsubType WHEN 24 THEN '24;4275;1;1;BANDO' WHEN 34 THEN '34;4303;1;1;BANDO' WHEN 48 THEN '48;4405;1;1;PRODUCTS3' WHEN 78 THEN '78;4303;2;0;BANDO' WHEN 68 THEN '68;4303;3;0;BANDO' END AS dcmisubtype, CAST(dcmIType AS varchar) + ';' + CAST(dcmIsubType AS varchar) AS documento
FROM         dbo.Document
WHERE     (dcmIType = 55) AND (dcmIsubType IN (24, 34, 48,78,68)) AND (dcmDeleted = 0)




GO
